defmodule AttoLink.AttoTest do
  use AttoLink.DataCase

  alias AttoLink.Atto

  describe "preview" do
    @valid_url "https://pusher.com/tutorials/collaborative-text-editor-javascript"

    def preview_fixture(url) do
      {:ok, preview} =
        url
        |> Atto.create_preview()

      preview
    end

    test "create_preview/1 with valid data creates a preview" do
      assert {:ok, %LinkPreview.Page{} = preview} = Atto.create_preview(@valid_url)
    end
  end
end
