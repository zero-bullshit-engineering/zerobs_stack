defmodule Mix.Tasks.CopyFeatureflagsMigrations do
  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Generator.copy_file(
      to_string(:code.priv_dir(:zerobs_stack)) <> "/files/fun_with_flags_migration_0.exs",
      "priv/repo/migrations/00000000000000_create_feature_flags_table.exs"
    )
  end
end
