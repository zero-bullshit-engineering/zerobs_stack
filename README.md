# ZerobsStack
The 0BS stack is a starting point for building Elixir and Phoenix applications, presented as an Elixir metapackage. It includes the following features:

- Featureflags (via fun_with_flags)
- Prometheus metrics (via telemetry)
- HTTP Client (Using Tesla with included telemetry reporting)
- Featureflags UI and Prometheus metrics on own port for easier securing
- Load shedding via feature flags per controller action ("Drop 50% of all requests to PageController#index")

### Planned features

- MQTT subscriber (with instrumentation)
- Rate limiting per route/user

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `zerobs_stack` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:zerobs_stack, "~> 0.1.0"}
  ]
end
```

## Usage

### Feature Flags

Run `mix copy_featureflags_migrations` to add the needed Ecto migrations to your `priv/repo/migrations` folder.


### Load shedding

Add `plug ZerobsSTack.LoadShedPlug` to the end of the `def controller do` block in your `ApplicationWeb` module. 

To enable load shedding open your FunWithFlags GUI and add a flag named like `elixir_stackerweb_pagecontroller_index_disabled`. This would drop Traffic for `Elixir.StackerWeb.PageController#index` (We downcase the whole module name and replace `.` with `_`.)
