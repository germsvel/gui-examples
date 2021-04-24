defmodule Gui.Temperature do
  def to_fahrenheit(celsius) do
    celsius * (9 / 5) + 32
  end

  def to_celsius(fahrenheit) do
    (fahrenheit - 32) * (5 / 9)
  end
end
