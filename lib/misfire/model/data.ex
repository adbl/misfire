defmodule Misfire.Model.Data do
  def cwd_path(file), do: "#{File.cwd!}/data/#{file}"

  def read_file(localpath), do: File.read cwd_path(localpath)
end