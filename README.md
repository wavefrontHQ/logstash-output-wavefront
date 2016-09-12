# Wavefront Logstash Output Plugin
Fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want.

## Contributing
All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

## Developing
To better understand contributing to logstash plugins, visit [their article on custom output plugins](https://www.elastic.co/guide/en/logstash/current/_how_to_write_a_logstash_output_plugin.html).

To test a local build of this plugin,

   1. Install logstash. Either from source or from a package manager is fine.
   1. Install ruby bundler -- `gem install bundler` should do it.
   1. In this directory, `gem build logstash-output-wavefront.gemspec`
   1. `logstash-plugin install *wavefront*.gem`

### Install dependencies
```
bundle install
```

### Test
```
bundle exec rspec
```

## Need Help?

support@wavefront.com
