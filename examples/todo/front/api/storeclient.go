package api

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
)

type HttpAccessLayer interface {
	Get(url string) ([]byte, error)
	Post(url string, contentType string, body []byte) ([]byte, error)
}

type HttpHAL struct {
	transport *http.Transport
	client    *http.Client
}

func NewHttpHAL() (*HttpHAL, error) {
	config := &tls.Config{
		InsecureSkipVerify: true,
	}
	transport := &http.Transport{TLSClientConfig: config}
	client := &http.Client{Transport: transport}

	hal := &HttpHAL{
		transport: transport,
		client:    client,
	}
	return hal, nil
}

func (h *HttpHAL) Get(url string) ([]byte, error) {
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		log.Printf("http.NewRequest was failed due to [%s].\n", err)
		return nil, err
	}

	resp, err := h.client.Do(req)
	if err != nil {
		log.Printf("http.Call was failed due to [%s].\n", err)
		return nil, err
	}
	b, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Printf("ioutil.ReadAll was failed due to [%s].\n", err)
		return nil, err
	}
	toJson("Get Response -> ", b)
	return b, nil
}

func (h *HttpHAL) Post(url string, contentType string, b []byte) ([]byte, error) {
	resp, err1 := http.Post(url, contentType, bytes.NewReader(b))
	if err1 != nil {
		log.Printf("API call was failed from %s with Err: %s. \n", url, err1)
		return nil, err1
	}
	defer resp.Body.Close()

	b, err2 := ioutil.ReadAll(resp.Body)
	if err2 != nil {
		log.Printf("Read buffer failed.\n")
	}
	toJson("Post Response -> ", b)
	return b, nil
}

func GetTodo(url string, name string) Todo {
	ts := GetTodos(url)
	for _, t := range ts {
		if t.Name == name {
			return t
		}
	}
	return Todo{}
}

func GetTodos(url string) []Todo {
	var t []Todo
	h, err := NewHttpHAL()
	b, err := h.Get(url)
	if err != nil {
		log.Printf("HttpAccessLayer.Get was failed due to [%s].\n", err)
		return nil
	}
	if b != nil {

		err := json.Unmarshal(b, &t)
		if err != nil {
			log.Println(err)
			return nil
		}

	}


	return t
}

func SaveTodo(url string, contentType string, td Todo) StoreResponse {
	var sr StoreResponse
	h, err := NewHttpHAL()
	if err != nil {
		log.Printf("HttpAccessLayer.Get was failed due to [%s].\n", err)
		return sr
	}
	tdb, err := json.Marshal(td)
	if err != nil {
		log.Printf("Marshal Todo was failed due to [%s]. \n", err)
	}
	b, err := h.Post(url, contentType, tdb)
	erm := json.Unmarshal(b, &sr)
	if err != nil {
		log.Println(erm)
		return sr
	}
	return sr
}

func toJson(title string, body []byte) {
	var prettyJSON bytes.Buffer
	error := json.Indent(&prettyJSON, body, "", "\t")
	if error != nil {
		log.Println("JSON parse error: ", error)
		return
	}
	log.Println(title, prettyJSON.String())

}