defmodule Gui.CircleDrawer do
  defmodule Circle do
    @beginning_radius 2
    @enforce_keys [:x, :y]
    defstruct x: nil, y: nil, r: @beginning_radius
    @type t :: %__MODULE__{}
  end

  defmodule Canvas do
    defstruct circles: [], selected: nil
    @type t :: %__MODULE__{circles: [Circle.t()], selected: Circle.t()}
  end

  defmodule History do
    def build, do: []
    def add_event(history, event), do: [event | history]

    def pop_event([]), do: :no_more_history
    def pop_event([event | rest]), do: {event, rest}
  end

  def new_canvas, do: %Canvas{}

  def new_circle(x, y), do: %Circle{x: x, y: y}

  def update_radius(circle, r), do: %Circle{circle | r: r}

  def add_circle(canvas, circle) do
    %{canvas | circles: [circle | canvas.circles]}
  end

  def update_selected(canvas, circle) do
    canvas
    |> update_circle(circle)
    |> select_circle(circle)
  end

  def update_circle(canvas, %{x: x, y: y} = circle) do
    index =
      Enum.find_index(canvas.circles, fn
        %{x: ^x, y: ^y} -> true
        _ -> false
      end)

    updated_circles = List.replace_at(canvas.circles, index, circle)

    %{canvas | circles: updated_circles}
  end

  def existing_circle(canvas, coordinates) do
    Enum.find(canvas.circles, &within_circle?(&1, coordinates))
  end

  def select_circle(canvas, circle) do
    %{canvas | selected: circle}
  end

  defp within_circle?(%Circle{x: circle_x, y: circle_y, r: radius}, {x, y}) do
    :math.pow(x - circle_x, 2) + :math.pow(y - circle_y, 2) <= :math.pow(radius, 2)
  end
end
