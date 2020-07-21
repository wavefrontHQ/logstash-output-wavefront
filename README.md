# Wavefront Logstash Output Plugin
Wavefront Output Plugin for Logstash parse the log data and sends it as metrics to the wavefront.

# Installation
### Install from Ruby Gem
```
gem install logstash-output-wavefront
```

### Install from Source
To Install from source follow the below steps:
   1. Install ruby.
   2. Install ruby bundler -- `gem install bundler`.
   3. Clone this repository and `cd` to the directory.
   4. Build the plugin -- `gem build logstash-output-wavefront.gemspec`.
   5. Install the plugin --`logstash-plugin install *wavefront*.gem`.

# Enable Output plugin
Create/Update a config file that specifies `wavefront` as output plugin
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

# Log Data Format
Wavefront output plugin for Logstash can only process the log data as metric which is in below format
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
Wavefront output plugin for Logstash generate below metrics out of the above log data and sends to Wavefront
```
logstash.bytes.count 200
logstash.bytes.mean 42.2
logstash.error.count 123
```
Wavefront output plugin for Logstash also supports sending point tags for a metric, below is the log data format
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
Below metrics are the output of the above log data
```
logstash.bytes.count 200 type=access region=mumbai
logstash.bytes.mean 42.2 type=access region=mumbai
logstash.error.count 123
```

**Note:** Wavefront output plugin for Logstash has dropped out the `logstash.error.code` metric, as default `metrics` list only includes `count and mean`, to include the `code` metric you have to override the default `metrics` to `["count", "mean", "code"]`.

# Start The Service
Start logstash and specify the configuration file with the -f flag.
```
bin/logstash -f <config-file>
```

# License
[Apache 2.0 License](LICENSE).

# How to Contribute

* Reach out to us on our public [Slack channel](https://www.wavefront.com/join-public-slack).
* If you run into any issues, let us know by creating a GitHub issue.