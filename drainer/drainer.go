package main

// original from https://github.com/ktruckenmiller/aws-ecs-spot-instance-drainer

import (
  "encoding/json"
  "fmt"
  "io/ioutil"
  "log"
  "net/http"
  "os"
  "time"

  // "strings"
  "github.com/aws/aws-sdk-go/aws"
  "github.com/aws/aws-sdk-go/aws/session"
  "github.com/aws/aws-sdk-go/service/ecs"
)
type instance struct {
  Cluster string `json:"Cluster"`
  Arn string `json:"ContainerInstanceArn"`
}
func getContainerInstance() instance {
  client := http.Client{
    Timeout: time.Second * 2, // Maximum of 2 secs
  }
  containerInstance := instance{}
  req, err := http.NewRequest(http.MethodGet, "http://0.0.0.0:51678/v1/metadata", nil)
  if err != nil {
    log.Fatal(err)
  }

  res, getErr := client.Do(req)
  if getErr != nil {
    fmt.Println(getErr)
    return containerInstance
    // log.Fatal(getErr)
  }
  body, readErr := ioutil.ReadAll(res.Body)
  if readErr != nil {
    log.Fatal(readErr)
  }

  jsonErr := json.Unmarshal(body, &containerInstance)
  if jsonErr != nil {
    log.Fatal(jsonErr)
  }
  fmt.Printf("HTTP: %s\n", res.Status)
  return containerInstance
}

func isStopping() bool {
  client := http.Client{
    Timeout: time.Second * 2, // Maximum of 2 secs
  }
  ec2_url := os.Getenv("EC2METADATA_URL")
  if ec2_url == "" {
    ec2_url = "169.254.169.254"
  }
  url := fmt.Sprintf("http://%s/latest/meta-data/spot/termination-time", ec2_url)
  req, err := http.NewRequest(http.MethodGet, url, nil)
  if err != nil {
    log.Fatal(err)

  }
  res, getErr := client.Do(req)
  if getErr != nil {
    log.Fatal(getErr)
  }
  fmt.Println("Checking spot status...")
  return res.StatusCode == 200
}

func drain(containerInstance instance) {
  // ecs stuff
  svc := ecs.New(session.New())

  input := &ecs.UpdateContainerInstancesStateInput {
    ContainerInstances: []*string{aws.String(containerInstance.Arn)},
    Cluster: aws.String(containerInstance.Cluster),
    Status: aws.String("DRAINING"),
  }
  req, resp := svc.UpdateContainerInstancesStateRequest(input)
  err := req.Send()
  if err != nil { // resp is now filled
    fmt.Println(resp)
    fmt.Println(err)
  }
  fmt.Println("Successfully drained the instance")
  os.Exit(0)
}

func main() {

  containerInstance := getContainerInstance()

  for containerInstance == (instance{}) {
    fmt.Println("Cannot communicate with ECS Agent. Retrying...")
    time.Sleep(time.Second * 5)
    containerInstance = getContainerInstance()
  }
  fmt.Printf("Found ECS Container Instance %s\n", containerInstance.Arn)
  fmt.Printf("on the %s cluster.\n", containerInstance.Cluster)

  for true {
    if isStopping() {
      fmt.Println("Spot instance is being acted upon. Doing something")
      fmt.Printf("Drain this %s\n", containerInstance.Arn)
      // drain this one
      drain(containerInstance)
    }

    time.Sleep(time.Second * 5)
  }
}