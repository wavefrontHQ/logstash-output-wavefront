# Wavefront Logstash Output Plugin
Wavefront Output Plugin for Logstash parse the log data and sends it as metrics to the Wavefront.

# Installation
1. Install Wavefront Logstash Output Plugin
    - Install ruby.
    - Install ruby bundler -- `gem install bundler`.
    - Clone [logstash-output-wavefront](https://github.com/wavefrontHQ/logstash-output-wavefront) and `cd` to the directory.
    - Build the plugin -- `gem build logstash-output-wavefront.gemspec`.
    - Install the plugin --`logstash-plugin install *wavefront*.gem`.


2. Create a config file that specifies wavefront as the output plugin and specifies settings for other plugins. You can see some examples under Optional Configuration below.
    ```
    output {
        wavefront {
          host => "<Proxy-IP>"
        }
    }
    ```
    Optional Configuration
    ```
      port          Metric Port (Default - 2878)
      prefix        Metric Prefix (Default - "logstash")
      metrics       List of metrics (Default - ["count", "mean"])
      source        Metric source (Default - Hostname of the node running logstash)
    ```

   You can send log events to Wavefront using the output plugin for Logstash. The events must have the following format:
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
    You can send point tags for a metric to Wavefront using the Wavefront output plugin for Logstash. The event must have the following format:
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


3. Start logstash and specify the configuration file with the -f flag.
    ```
    bin/logstash -f <config-file>
    ```

# License
[Apache 2.0 License](LICENSE).

# How to Contribute

* Reach out to us on our public [Slack channel](https://www.wavefront.com/join-public-slack).
* If you run into any issues, let us know by creating a GitHub issue.
