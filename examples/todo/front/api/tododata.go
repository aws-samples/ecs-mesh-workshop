package api

import "time"

type Todo struct {
	ID	string `json:"id"`
	Name      string    `json:"name"`
	Description string `json:"description"`
	Completed bool      `json:"completed"`
	Due       time.Time `json:"due"`
	Create	time.Time `json:"create"`
	Owner	string	`json:"owner"`
}

type StoreResponse struct {
	Status      string    `json:"status"`
	Description string `json:"description"`

}

type Todos []Todo

