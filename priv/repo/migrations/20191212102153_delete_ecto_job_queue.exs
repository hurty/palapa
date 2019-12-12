defmodule Palapa.Repo.Migrations.DeleteEctoJobQueue do
  use Ecto.Migration

  def change do
    EctoJob.Migrations.CreateJobTable.down("jobs")
    EctoJob.Migrations.Install.down()
  end
end
