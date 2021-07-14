defmodule GuiWeb.TimerLiveTest do
  use GuiWeb.ConnCase

  import Phoenix.LiveViewTest

  alias GuiWeb.TimerLive

  test "renders a Timer", %{conn: conn} do
    {:ok, view, html} = live(conn, "/timer")

    assert html =~ "Timer"
    assert view |> elapsed_time_gauge() |> has_element?()
    assert view |> elapsed_time() |> has_element?()
    assert view |> duration_slider() |> has_element?()
    assert view |> reset_button() |> has_element?()
  end

  test "elapsed time is updated with every tick", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/timer")

    TimerLive.tick(view.pid)
    TimerLive.tick(view.pid)

    assert view |> elapsed_time("2 s") |> has_element?()
    assert view |> elapsed_time_gauge("2") |> has_element?()
  end

  test "duration slider changes maximum elapsed time", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/timer")

    view
    |> duration_slider()
    |> render_hook("update-duration", %{"value" => "10"})

    assert view |> max_elapsed_time("10") |> has_element?()
  end

  test "user can reset elapsed time", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/timer")
    TimerLive.tick(view.pid)

    view
    |> reset_button()
    |> render_click()

    assert view |> elapsed_time("0 s") |> has_element?()
    assert view |> elapsed_time_gauge("0") |> has_element?()
  end

  test "elapsed time stops when it is equal to duration", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/timer")

    view
    |> set_duration(to: "2")
    |> tick()
    |> tick()
    |> tick()

    assert view |> elapsed_time("2 s") |> has_element?()
    assert view |> elapsed_time_gauge("2") |> has_element?()
  end

  def tick(view) do
    TimerLive.tick(view.pid)
    view
  end

  def set_duration(view, to: value) do
    view
    |> duration_slider()
    |> render_hook("update-duration", %{"value" => value})

    view
  end

  defp max_elapsed_time(view, max) do
    element(view, "#elapsed-time-gauge[max=#{max}]")
  end

  defp elapsed_time_gauge(view, text \\ nil) do
    element(view, "#elapsed-time-gauge", text)
  end

  defp elapsed_time(view, text \\ nil) do
    element(view, "#elapsed-time", text)
  end

  defp duration_slider(view) do
    element(view, "#duration-slider")
  end

  defp reset_button(view) do
    element(view, "#reset")
  end
end
