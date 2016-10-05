defmodule Benchee.Conversion.Format do
  @moduledoc """
  Functions for formatting values and their unit labels. Different domains
  handle this task differently, for example durations and counts.

  See `Benchee.Conversion.Count` and `Benchee.Conversion.Duration` for examples
  """

  alias Benchee.Conversion.Unit

  @doc """
  Formats a number as a string, with a unit label. See `Benchee.Conversion.Count`
  and `Benchee.Conversion.Duration` for examples
  """
  @callback format(number) :: String.t

  @doc """
  A string that appears between a value and a unit label when formatted as a
  String. For example, a space: `5.67 M` or an empty string: `5.67M`
  """
  @callback separator :: String.t

  # Generic formatting functions

  @doc """
  Formats a unit value with specified label and separator
  """
  def format({count, _unit}, label, separator) do
    separator = separator(label, separator)
    "~.#{float_precision(count)}f~ts~ts"
    |> :io_lib.format([count, separator, label])
    |> to_string
  end

  @doc """
  Formats a unit value with the label and separator supplied by `module`. The
  specified module should provide `label/1` and `separator/0` functions
  """
  def format({count, unit}, module) do
    format({count, unit}, label(module, unit), module.separator)
  end

  @doc """
  Scales a number to the most appropriate unit, and formats the scaled value
  with the label and separator supplied by `module`. The
  specified module should provide `label/1` and `separator/0` functions
  """
  def format(number, module) do
    number
    |> module.scale
    |> format(module)
  end

  # Returns the separator, or an empty string if there isn't a label
  defp separator(label, _separator) when label == "" or label == nil, do: ""
  defp separator(_label, separator), do: separator

  # Fetches the label for the given unit
  defp label(module, unit) do
    Unit.label(module, unit)
  end

  defp float_precision(float) when float < 0.01, do: 5
  defp float_precision(float) when float < 0.1, do: 4
  defp float_precision(float) when float < 0.2, do: 3
  defp float_precision(_float), do: 2

end
