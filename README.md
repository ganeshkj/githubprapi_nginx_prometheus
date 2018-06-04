# GitHubPR status API - Nginx Prometheus Metrics

A simple github pull requests status and collect prometheus metrics for nginx, version 1.11.4 or above recommended.

[Docker Hub: avava/githubpr](https://hub.docker.com/r/avava/githubpr)

## How to build

```sh
docker build -t githubpr .
```

## How to run

```sh
docker run -d --rm -it -p 80:80 -p 9147:9147 githubpr
```

or pull image directly from Dockerhub and run as below

```sh
docker pull avava/githubpr
docker run -d --rm -it -p 80:80 -p 9147:9147 avava/githubpr:0.1.12
```

Visit [http://localhost](http://localhost) to generate some test metrics.

Then visit [http://localhost:9147/metrics](http://localhost:9147/metrics) in your browser(safari/chrome).

And you will see the prometheus output below:
```
# HELP nginx_http_request_duration_seconds HTTP request latency
# TYPE nginx_http_request_duration_seconds histogram
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.005"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.010"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.020"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.030"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.050"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.075"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.100"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.200"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.300"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.400"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.500"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="00.750"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="01.000"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="01.500"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="02.000"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="03.000"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="04.000"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="05.000"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="10.000"} 1
nginx_http_request_duration_seconds_bucket{host="localhost",le="+Inf"} 1
nginx_http_request_duration_seconds_count{host="localhost"} 1
nginx_http_request_duration_seconds_sum{host="localhost"} 0
# HELP nginx_http_requests Number of HTTP requests
# TYPE nginx_http_requests histogram
nginx_http_requests_bucket{host="localhost",status="200",le="01.000"} 1
nginx_http_requests_bucket{host="localhost",status="200",le="01.500"} 1
nginx_http_requests_bucket{host="localhost",status="200",le="02.000"} 1
nginx_http_requests_bucket{host="localhost",status="200",le="03.000"} 1
nginx_http_requests_bucket{host="localhost",status="200",le="04.000"} 1
nginx_http_requests_bucket{host="localhost",status="200",le="05.000"} 1
nginx_http_requests_bucket{host="localhost",status="200",le="10.000"} 1
nginx_http_requests_bucket{host="localhost",status="200",le="+Inf"} 1
nginx_http_requests_count{host="localhost",status="200"} 1
nginx_http_requests_sum{host="localhost",status="200"} 1
# HELP nginx_metric_errors_total Number of nginx-lua-prometheus errors
# TYPE nginx_metric_errors_total counter
nginx_metric_errors_total 0

```
You can use the PromQL to find the below
- Average no of req/s per 1 second as measured over the last 5 minutes

	```
	rate(nginx_http_requests_count[5m])
	or
	rate(nginx_http_requests_count{status=500}[5m])
	or
	sum(rate(nginx_http_requests_count[5m])) by (status)
	```

- Average request latency per 1 second as measured over the last 5 minutes
	```
	rate(nginx_http_request_duration_seconds_count[5m])
	```
