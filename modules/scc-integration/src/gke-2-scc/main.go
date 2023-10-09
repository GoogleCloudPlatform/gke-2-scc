// Copyright 2023 Google LLC

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     https://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package gke2scc

import (
	"context"
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"github.com/cloudevents/sdk-go/v2/event"
	"google.golang.org/protobuf/types/known/structpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	securitycenter "cloud.google.com/go/securitycenter/apiv1"
	"cloud.google.com/go/securitycenter/apiv1/securitycenterpb"
)

// MessagePublishedData contains the full Pub/Sub message
// See the documentation for more details:
// https://cloud.google.com/eventarc/docs/cloudevents#pubsub
type MessagePublishedData struct {
	Message PubSubMessage
}

// PubSubMessage is the payload of a Pub/Sub event.
// See the documentation for more details:
// https://cloud.google.com/pubsub/docs/reference/rest/v1/PubsubMessage
type PubSubMessage struct {
	Data []byte `json:"data"`
}

type AuditLog struct {
	InsertID         string         `json:"insertId"`
	Labels           AuditLogLabels `json:"labels"`
	LogName          string         `json:"logName"`
	Operation        Operation      `json:"operation"`
	ProtoPayload     ProtoPayload   `json:"protoPayload"`
	ReceiveTimestamp string         `json:"receiveTimestamp"`
	Resource         Resource       `json:"resource"`
	Timestamp        time.Time      `json:"timestamp"`
}

type AuditLogLabels struct {
	AuthorizationK8SIoDecision string `json:"authorization.k8s.io/decision"`
	AuthorizationK8SIoReason   string `json:"authorization.k8s.io/reason"`
}

type Operation struct {
	First    bool   `json:"first"`
	ID       string `json:"id"`
	Producer string `json:"producer"`
}

type ProtoPayload struct {
	Type               string              `json:"@type"`
	AuthenticationInfo AuthenticationInfo  `json:"authenticationInfo"`
	AuthorizationInfo  []AuthorizationInfo `json:"authorizationInfo"`
	MethodName         string              `json:"methodName"`
	RequestMetadata    RequestMetadata     `json:"requestMetadata"`
	ResourceName       string              `json:"resourceName"`
	ServiceName        string              `json:"serviceName"`
	Status             Status              `json:"status"`
}

type AuthenticationInfo struct {
	PrincipalEmail string `json:"principalEmail"`
}

type AuthorizationInfo struct {
	Granted    bool   `json:"granted"`
	Permission string `json:"permission"`
	Resource   string `json:"resource"`
}

type RequestMetadata struct {
	CallerIP                string `json:"callerIp"`
	CallerSuppliedUserAgent string `json:"callerSuppliedUserAgent"`
}

type Status struct {
}

type Resource struct {
	Labels ResourceLabels `json:"labels"`
	Type   string         `json:"type"`
}

type ResourceLabels struct {
	ClusterName string `json:"cluster_name"`
	Location    string `json:"location"`
	ProjectID   string `json:"project_id"`
}

var sourceId string
var findingConfig map[string]*FindingConfig

type FindingConfig struct {
	Category string                            `json:"category"`
	Severity securitycenterpb.Finding_Severity `json:"severity"`
}

func init() {
	sourceId = os.Getenv("SCC_SOURCE_ID")
	findingConfigEncoded := os.Getenv("SCC_FINDING_CONFIG")
	json.Unmarshal([]byte(findingConfigEncoded), &findingConfig)

	fmt.Printf("SourceId: %s", sourceId)
	functions.CloudEvent("Handler", handler)
}

func GetFindingConfigForMethod(m string) *FindingConfig {
	if v, ok := findingConfig[m]; ok {
		return v
	} else {
		return findingConfig["DEFAULT"]
	}
}

func handler(ctx context.Context, e event.Event) error {

	var msg MessagePublishedData
	var event *AuditLog

	if err := e.DataAs(&msg); err != nil {
		return fmt.Errorf("event.DataAs: %w", err)
	}

	fmt.Println(string(msg.Message.Data))

	if err := json.Unmarshal(msg.Message.Data, &event); err != nil {
		log.Printf("data json.NewDecoder: %v", err)
		return err
	}

	fmt.Printf("%+v\n", *event)

	err := createFindingWithProperties(event)
	if err != nil {
		log.Fatal(err.Error())
	}

	return nil
}

func createFindingWithProperties(l *AuditLog) error {

	ctx := context.Background()

	client, err := securitycenter.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("securitycenter.NewClient: %w", err)
	}

	defer client.Close()
	eventTime := timestamppb.New(l.Timestamp)
	fid := fmt.Sprintf("%s-%s-%s-%s-%d", l.Resource.Labels.ProjectID, l.Resource.Labels.ClusterName, l.ProtoPayload.ResourceName, l.ProtoPayload.MethodName, l.Timestamp.Unix())

	h := md5.Sum([]byte(fid))
	fidsum := hex.EncodeToString(h[:])

	fmt.Println(fidsum)

	fconfig := GetFindingConfigForMethod(l.ProtoPayload.MethodName)
	req := &securitycenterpb.CreateFindingRequest{
		Parent:    sourceId,
		FindingId: fidsum,
		Finding: &securitycenterpb.Finding{
			State:        securitycenterpb.Finding_ACTIVE,
			ResourceName: l.ProtoPayload.ResourceName,
			Category:     (*fconfig).Category,
			Severity:     (*fconfig).Severity,
			EventTime:    eventTime,
			Access: &securitycenterpb.Access{
				PrincipalEmail: l.ProtoPayload.AuthenticationInfo.PrincipalEmail,
				CallerIp:       l.ProtoPayload.RequestMetadata.CallerIP,
				MethodName:     l.ProtoPayload.MethodName,
				UserAgent:      l.ProtoPayload.RequestMetadata.CallerSuppliedUserAgent,
				ServiceName:    l.ProtoPayload.ServiceName,
			},
			// Define key-value pair metadata to include with the finding.
			SourceProperties: map[string]*structpb.Value{
				"log_name": {
					Kind: &structpb.Value_StringValue{StringValue: l.LogName},
				},
				"producer": {
					Kind: &structpb.Value_StringValue{StringValue: l.Operation.Producer},
				},
				"cluster_name": {
					Kind: &structpb.Value_StringValue{StringValue: l.Resource.Labels.ClusterName},
				},
				"location": {
					Kind: &structpb.Value_StringValue{StringValue: l.Resource.Labels.Location},
				},
				"project_id": {
					Kind: &structpb.Value_StringValue{StringValue: l.Resource.Labels.ProjectID},
				},
			},
		},
	}

	finding, err := client.CreateFinding(ctx, req)
	if err != nil {
		return fmt.Errorf("CreateFinding: %w", err)
	}

	fmt.Printf("New finding created: %s => %s\n", finding.Name, req.String())

	return nil
}
