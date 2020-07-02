# Wavefront Logstash Output Plugin
The Wavefront output plugin for Logstash enables sending Logstash event metrics to Wavefront.

# Setup
Install Wavefront Logstash Output Plugin
```
gem install logstash-output-wavefront
```
# Enable
Enable Wavefront Output plugin for Logstash
```
output {
    wavefront {
      host => "<Proxy-IP>"
    }
}
```
#### Optional Configuration
```
  port          Metric Port (Default - 2878)
  prefix        Metric Prefix (Default - "logstash")
  metrics       List of metrics (Default - ["count", "mean"])
  source        Metric source (Default - Hostname of the node running logstash)  
```
# Event Formate
Wavefront output plugin for Logstash can only process the event as metric which is in below formate
```
{
   "bytes" => {
     "count" => 200,
     "mean" => 42.2
   },
   "error" => {
     "count" => 123,
     "code" => 404
   },
   "message" => "I'm not a hash type, so I won't get sent."
 }
```
Wavefront output plugin for Logstash generate below metrics out of the above event and sends to Wavefront
```
logstash.bytes.count 200
logstash.bytes.mean 42.2
logstash.error.count 123
```
Wavefront output plugin for Logstash also supports sending point tags for a metric, below is the event formate
```
{
   "bytes.tagz.type=access.region=mumbai" => {
     "count" => 200,
     "mean" => 42.2
   },
   "error" => {
     "count" => 123,
     "code" => 404
   },
   "message" => "I'm not a hash type, so I won't get sent."
 }
```
Below metrics are the output of the above event
```
logstash.bytes.count 200 type=access region=mumbai
logstash.bytes.mean 42.2 type=access region=mumbai
logstash.error.count 123
```

**Note:** Wavefront output plugin for Logstash has dropped out the `logstash.error.code` metric, as default `metrics` list only includes `count and mean`, to include the `code` metric you have to override the default `metrics` to `["count", "mean", "code"]`.

## License
[Apache 2.0 License](LICENSE).

## How to Contribute

* Reach out to us on our public [Slack channel](https://www.wavefront.com/join-public-slack).
* If you run into any issues, let us know by creating a GitHub issue.