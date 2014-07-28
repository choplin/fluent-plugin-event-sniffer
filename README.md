# Fluent::Plugin::Event::Sniffer

Fluentd event sniffing tool

![example of tool](https://raw.githubusercontent.com/choplin/fluent-plugin-event-sniffer/master/img/example.png)

## Demo

http://youtu.be/_ykzeP2xGNg

## Notice

This tool will modify the core module of fluentd, Enigne, using `instance_eval`. There is a potential risk that the fluentd process could be broken unexpectedly.

In addition, this tool might degrade the perfermance of the running fluentd process.

Therefore, this tool should be considered as a development or troubleshooting tool for now.

Use this tool at your own risk.

## Installation

`$ fluent-gem install fluent-plugin-event-sniffer`

## Configuration

### Example

```
<source>
  type event_sniffer
  pattern_bookmarks [
    "test.**",
    "debug.**"
  ]
</source>
```

### Parameter

key               | type    | description                                                       | required | default
---               | ---     | ---                                                               | ---      | ---
bind              | string  | Listen address                                                    | no       | 0.0.0.0
port              | integer | Listen port                                                       | no       | 8765
pattern_bookmarks | array   | Predefined patters. You can choose these patterns on the sidebar. | no       | []
max_events        | integer | Maximum number of displayed events.                               | no       | 10
refresh_interval  | integer | Event refresh interval.                                           | no       | 1

## Copyright

* Copyright (c) 2014- OKUNO Akihiro
* License
    * Apache License, version 2.0
