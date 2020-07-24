# Wavefront Logstash Output Plugin
Wavefront Output Plugin for Logstash parse the log data and sends it as metrics to the Wavefront.

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
Create a config file that specifies `wavefront` as output plugin and settings for other plugins.
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
The Wavefront output plugin for Logstash can process only events that have the following format:
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
The Wavefront output plugin for Logstash generates the following metrics from the event and sends the metrics to Wavefront:
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
Below metrics are the output of the above event:
```
logstash.bytes.count 200 type=access region=mumbai
logstash.bytes.mean 42.2 type=access region=mumbai
logstash.error.count 123
```

**Note:** In this example the Wavefront output plugin has dropped the `logstash.error.code` metric because the default `metrics` list only includes `count` and `mean`. To include the `code` metric, override the default `metrics` to `["count", "mean", "code"]` in the `wavefront` output plugin.

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
