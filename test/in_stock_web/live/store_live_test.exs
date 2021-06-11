defmodule InStockWeb.StoreLiveTest do
  use InStockWeb.ConnCase

  import Phoenix.LiveViewTest

  alias InStock.Stores

  @create_attrs %{name: "some name", price_selector: "some price_selector", stock_matcher: "some stock_matcher", stock_selector: "some stock_selector", url: "some url"}
  @update_attrs %{name: "some updated name", price_selector: "some updated price_selector", stock_matcher: "some updated stock_matcher", stock_selector: "some updated stock_selector", url: "some updated url"}
  @invalid_attrs %{name: nil, price_selector: nil, stock_matcher: nil, stock_selector: nil, url: nil}

  defp fixture(:store) do
    {:ok, store} = Stores.create_store(@create_attrs)
    store
  end

  defp create_store(_) do
    store = fixture(:store)
    %{store: store}
  end

  describe "Index" do
    setup [:create_store]

    test "lists all stores", %{conn: conn, store: store} do
      {:ok, _index_live, html} = live(conn, Routes.store_index_path(conn, :index))

      assert html =~ "Listing Stores"
      assert html =~ store.name
    end

    test "saves new store", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.store_index_path(conn, :index))

      assert index_live |> element("a", "New Store") |> render_click() =~
               "New Store"

      assert_patch(index_live, Routes.store_index_path(conn, :new))

      assert index_live
             |> form("#store-form", store: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#store-form", store: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.store_index_path(conn, :index))

      assert html =~ "Store created successfully"
      assert html =~ "some name"
    end

    test "updates store in listing", %{conn: conn, store: store} do
      {:ok, index_live, _html} = live(conn, Routes.store_index_path(conn, :index))

      assert index_live |> element("#store-#{store.id} a", "Edit") |> render_click() =~
               "Edit Store"

      assert_patch(index_live, Routes.store_index_path(conn, :edit, store))

      assert index_live
             |> form("#store-form", store: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#store-form", store: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.store_index_path(conn, :index))

      assert html =~ "Store updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes store in listing", %{conn: conn, store: store} do
      {:ok, index_live, _html} = live(conn, Routes.store_index_path(conn, :index))

      assert index_live |> element("#store-#{store.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#store-#{store.id}")
    end
  end

  describe "Show" do
    setup [:create_store]

    test "displays store", %{conn: conn, store: store} do
      {:ok, _show_live, html} = live(conn, Routes.store_show_path(conn, :show, store))

      assert html =~ "Show Store"
      assert html =~ store.name
    end

    test "updates store within modal", %{conn: conn, store: store} do
      {:ok, show_live, _html} = live(conn, Routes.store_show_path(conn, :show, store))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Store"

      assert_patch(show_live, Routes.store_show_path(conn, :edit, store))

      assert show_live
             |> form("#store-form", store: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#store-form", store: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.store_show_path(conn, :show, store))

      assert html =~ "Store updated successfully"
      assert html =~ "some updated name"
    end
  end
end
