package api

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"log"
	"net/http"
	"os"
)


var StoreServiceUrl = os.Getenv("STORE_SERVICE_URL")

func Index(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Welcome to TODO service with explored spirit.")
}

func TodoIndex(w http.ResponseWriter, r *http.Request) {
	t := GetTodos(StoreServiceUrl+"/todos")
	b, err := json.Marshal(t)
	w.Header().Add("Content-Type", "application/json")
	if err != nil {
		log.Println(err)
		fmt.Fprintf(w, `{"status":"error", "description":"%s"}`, err)
	}
	fmt.Fprintf(w, "Todo Index: %s\n", b)
}

func TodoShow(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	w.Header().Add("Content-Type", "application/json")
	todoName := vars["name"]
	t := GetTodo(StoreServiceUrl+"/todos", todoName)
	if t.Name == "" {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, `{"status":"error", "description":"todo [%s] wasn't existed'"}`, todoName)
		return
	}
	b, _ := json.Marshal(t)
	fmt.Fprintf(w, "%s", b)
}


func TodoSave(w http.ResponseWriter, r *http.Request) {
	var td Todo
	w.Header().Add("Content-Type", "application/json")
	err := json.NewDecoder(r.Body).Decode(&td)
	if err!=nil {
		log.Println(err)
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, `{"status":"error", "description":"%s"}`, err)
		return
	}
	sr := SaveTodo(StoreServiceUrl+"/todo","application/json", td )
	if sr.Status == "error" {
		w.WriteHeader(http.StatusBadRequest)
	}
	b, _ := json.Marshal(sr)
	fmt.Fprintf(w,"%s", b)
}