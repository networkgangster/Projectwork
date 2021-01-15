package main

import (
	"context"
	"flag"
	"github.com/exoscale/egoscale"
	"log"
	"net/http"
)

type requestHandler struct {
	client      *egoscale.Client
	poolId      *egoscale.UUID
	minPoolSize int
	maxPoolSize int
	zoneId      *egoscale.UUID
}

func (handler *requestHandler) getInstancePool() *egoscale.InstancePool {
	ctx := context.Background()
	resp, err := handler.client.RequestWithContext(ctx, egoscale.GetInstancePool{
		ZoneID: handler.zoneId,
		ID:     handler.poolId,
	})
	if err != nil {
		log.Printf("failed to get instance pool from Exoscale (%v)", err)
		// Ignore error. next run will hopefully work better
		return nil
	}
	response := resp.(egoscale.GetInstancePoolResponse)
	if len(response.InstancePools) == 0 {
		log.Fatalf("instance pool not found")
	} else if len(response.InstancePools) > 1 {
		//This should never happen
		log.Fatalf("more than one instance pool returned")
	}
	return &response.InstancePools[0]
}

func (handler *requestHandler) scaleInstancePool(size int) {
	ctx := context.Background()
	resp, err := handler.client.RequestWithContext(ctx, egoscale.ScaleInstancePool{
		ZoneID: handler.zoneId,
		ID:     handler.poolId,
		Size:   size,
	})
	if err != nil {
		log.Printf("failed to scale instance pool on Exoscale (%v)", err)
		// Ignore error. next run will hopefully work better
		return
	}
	response := resp.(egoscale.BooleanResponse)
	if !response.Success {
		log.Printf("failed to scale instance pool on Exoscale (API returned false)")
	}
}

func (handler *requestHandler) up(_ http.ResponseWriter, _ *http.Request) {
	instancePool := handler.getInstancePool()
	if instancePool == nil {
		// Instance pool not found, try next round
		return
	}
	if instancePool.Size <= handler.maxPoolSize {
		handler.scaleInstancePool(instancePool.Size + 1)
	}
}

func (handler *requestHandler) down(_ http.ResponseWriter, _ *http.Request) {
	instancePool := handler.getInstancePool()
	if instancePool == nil {
		// Instance pool not found, try next round
		return
	}
	if instancePool.Size >= handler.minPoolSize {
		handler.scaleInstancePool(instancePool.Size - 1)
	}
}

func main() {
	instancePoolId := ""
	minimumSize := 2
	maximumSize := 10
	exoscaleEndpoint := "https://api.exoscale.ch/v1/"
	exoscaleZoneId := ""
	exoscaleApiKey := ""
	exoscaleApiSecret := ""
	flag.StringVar(
		&instancePoolId,
		"instance-pool-id",
		instancePoolId,
		"ID of the instance pool to manage",
	)
	flag.StringVar(
		&exoscaleZoneId,
		"exoscale-zone-id",
		exoscaleZoneId,
		"Exoscale zone ID",
	)
	flag.IntVar(
		&minimumSize,
		"min-pool-size",
		minimumSize,
		"Minimum instance pool size not to scale below",
	)
	flag.IntVar(
		&maximumSize,
		"max-pool-size",
		maximumSize,
		"Maximum instance pool size not to scale above",
	)
	flag.StringVar(
		&exoscaleEndpoint,
		"exoscale-endpoint",
		exoscaleEndpoint,
		"Endpoint URL of the Exoscale API",
	)
	flag.StringVar(
		&exoscaleApiKey,
		"exoscale-api-key",
		exoscaleApiKey,
		"API key for Exoscale",
	)
	flag.StringVar(
		&exoscaleApiSecret,
		"exoscale-api-secret",
		exoscaleApiSecret,
		"API secret for Exoscale",
	)
	flag.Parse()

	zoneId, err := egoscale.ParseUUID(exoscaleZoneId)
	if err != nil {
		log.Fatalf("invalid zone ID (%v)", err)
	}

	poolId, err := egoscale.ParseUUID(instancePoolId)
	if err != nil {
		log.Fatalf("invalid pool ID (%v)", err)
	}

	handler := requestHandler{
		client:      egoscale.NewClient(exoscaleEndpoint, exoscaleApiKey, exoscaleApiSecret),
		zoneId:      zoneId,
		poolId:      poolId,
		minPoolSize: minimumSize,
		maxPoolSize: maximumSize,
	}

	http.HandleFunc("/up", handler.up)
	http.HandleFunc("/down", handler.down)
	err = http.ListenAndServe(":8090", nil)
	if err != nil {
		log.Fatalf("failed to launch webserver (%v)", err)
	}
}
