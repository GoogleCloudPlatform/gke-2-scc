package logging

import (
	"encoding/json"
	"log"
)

type LogEntry struct {
	Message  string `json:"message"`
	Severity string `json:"severity,omitempty"`
	Trace    string `json:"logging.googleapis.com/trace,omitempty"`

	Component string `json:"component,omitempty"`
}

func (e LogEntry) String() string {
	if e.Severity == "" {
		e.Severity = "INFO"
	}

	out, err := json.Marshal(e)
	if err != nil {
		log.Println(LogEntry{
			Severity: "ERROR",
			Message:  err.Error(),
		})
	}
	return string(out)
}
