package api

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

var WorkQueue = make(chan Todo, 200)

func TodoSave(w http.ResponseWriter, r *http.Request) {

	var td Todo

	log.Println(r.Body)
	err := json.NewDecoder(r.Body).Decode(&td)
	if err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, `{"status":"error", "description":"%s"}`, err)
		return
	}
	_, ok := LocalCache[td.Name]
	if ok {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, `{"status":"error", "description":"duplicated todo record."}`)
		return
	} else {

		WorkQueue <- td
		fmt.Fprintf(w, `{"status":"success", "description":"total records: %d"}`, len(LocalCache)+1)
	}
}

func TodoIndex(w http.ResponseWriter, r *http.Request) {
	values := []Todo{}
	for _, val := range LocalCache {
		values = append(values, val)
	}
	json.NewEncoder(w).Encode(values)
}

func ProcessMessage() {
	go func() {
		for {
			select {
			case work := <-WorkQueue:
				LocalCache[work.Name]=work
				//case <-w.QuitChan:
				//	// We have been asked to stop.
				//	fmt.Printf("worker%d stopping\n", w.ID)
				//	return
			}
		}
	}()
}