# AMS Benchmarking

## Benchmarks

### Comparison with other Serialization Libraries

```bash
cd benchmarks/serialization_libraries
bundle install
bundle exec ruby benchmark
```

yields

```plain
-- create_table("comments", {:force=>:cascade})
   -> 0.0066s
-- create_table("posts", {:force=>:cascade})
   -> 0.0029s
-- create_table("users", {:force=>:cascade})
   -> 0.0017s
Warming up --------------------------------------
    ams                  2.000  i/100ms
    jsonapi-rb           7.000  i/100ms
    ams        eager     2.000  i/100ms
    jsonapi-rb eager    12.000  i/100ms
Calculating -------------------------------------
    ams                  20.397  (± 1.7%) i/s -    204.000  in  10.097255s
    jsonapi-rb           74.981  (± 0.8%) i/s -    756.000  in  10.100857s
    ams        eager     23.117  (± 0.6%) i/s -    232.000  in  10.047664s
    jsonapi-rb eager    125.521  (± 0.8%) i/s -      1.260k in  10.054734s
                   with 95.0% confidence

Comparison:
    jsonapi-rb eager:      125.5 i/s
    jsonapi-rb      :       75.0 i/s - 1.67x  (± 0.02) slower
    ams        eager:       23.1 i/s - 5.43x  (± 0.05) slower
    ams             :       20.4 i/s - 6.15x  (± 0.12) slower
                   with 95.0% confidence

Calculating -------------------------------------
    ams                  2.688M memsize (   188.498k retained)
                        33.331k objects (     2.554k retained)
                        50.000  strings (    50.000  retained)
    jsonapi-rb           1.038M memsize (     0.000  retained)
                        11.784k objects (     0.000  retained)
                        50.000  strings (     0.000  retained)
    ams        eager     2.470M memsize (   184.410k retained)
                        30.534k objects (     2.439k retained)
                        50.000  strings (    50.000  retained)
    jsonapi-rb eager   715.124k memsize (     0.000  retained)
                         7.500k objects (     0.000  retained)
                        50.000  strings (     0.000  retained)

Comparison:
    jsonapi-rb eager:     715124 allocated
    jsonapi-rb      :    1037676 allocated - 1.45x more
    ams        eager:    2469640 allocated - 3.45x more
    ams             :    2688112 allocated - 3.76x more

```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
