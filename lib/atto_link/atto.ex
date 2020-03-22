defmodule AttoLink.Atto do
  @moduledoc """
  The Atto context.
  """
  use TODO
  import Ecto.Query, warn: false
  alias AttoLink.Repo
  alias LinkPreview
  alias AttoLink.Atto.Preview
  alias AttoLink.Accounts.User

  @doc """
  Returns the list of preview.

  ## Examples

      iex> list_preview()
      [%Preview{}, ...]

  """
  def list_preview do
    Repo.all(Preview)
  end

  @doc """
  Gets a single preview.

  Raises `Ecto.NoResultsError` if the Preview does not exist.

  ## Examples

      iex> get_preview!(123)
      %Preview{}

      iex> get_preview!(456)
      ** (Ecto.NoResultsError)

  """
  def get_preview!(url) do
    Repo.get_by!(Preview, url: url)
  end

  def get_preview(url) do
    Repo.get_by(Preview, url: url)
  end

  def get_cache_html_page(id) do
    Repo.get(Preview, id)
  end

  @doc """
  Creates a preview.

  ## Examples

      iex> create_preview(%{field: value})
      {:ok, %Preview{}}

      iex> create_preview(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_preview(url) do
    preview = LinkPreview.create(url)
    preview
  end

  def create_preview!(url) do
    LinkPreview.create!(url)
  end

  @todo "0.0.1": "Save html page instead/save html page too"
  @todo "add @spec and @moduledoc"
  def cache_preview(
        %User{email: email, id: _id, } = user,
        %LinkPreview.Page{original_url: _original_url} = attrs
      ) do
    IO.puts "Cache preview"
    with {:ok, _sum} <- check_html_throttle(user),
        {:ok, path, byte_size} <- save_html_page(email, attrs),
         {:ok, %Preview{}} = result <-
           Preview.changeset(%Preview{}, Map.from_struct(attrs) |> Enum.into(%{path: path, byte_size: byte_size})) |> Repo.insert() do
      result
    else
      {:error, %Ecto.Changeset{}} -> {:error, %Ecto.Changeset{}}
     {:deny, :exceeded_file_store_limit, _limit} = err -> err
      {:error, reason} -> {:error, reason}
      error -> error
    end
  end

  def check_html_throttle(%User{email: _email, plan: plan, id: id}) do
    %AttoLink.Atto.Plan{storage_limit: storage_limit} = AttoLink.Atto.Plan.plan_type(plan)
    #get the size of each folder.
    query = from preview in Preview,
            where: preview.user_id == ^id
    sum = AttoLink.Repo.aggregate(query, :sum, :byte_size)
    IO.puts "this is the sum #{sum}"
    if storage_limit > sum do
      {:ok, sum}
    else
      {:deny, :exceeded_file_store_limit, sum}
    end

  end
  @spec save_html_page(String.t(), LinkPreview.Page.t()) :: {:ok,  String.t(), non_neg_integer}
  defp save_html_page(email, %LinkPreview.Page{original_url: original_url, title: title}) do
    {:ok, %Tesla.Env{body: body}} = Tesla.get(original_url)
    # get a reference to the file in question.
    path = Path.expand("./www/app/files/user/#{email}/")

    if File.exists?(path) do
      # if the file already exists save it

      joined_path = [path, "#{title}.html"]
      |> Path.join()
      |> Path.absname()

      with :ok <- File.write(joined_path, body, [:write, :utf8]),
           {:ok, %File.Stat{size: size}} <- File.stat(joined_path) do
            {:ok, joined_path, size}
           else
              err -> err
           end


    else
      # since the file doesn't exist, generate it
      # generate the folder

      with :ok <- File.mkdir_p(path),
           joined_path <- [path, "#{title}.html"] |> Path.join |> Path.absname() do

           {File.write(joined_path, body, [:write, :utf8]), joined_path}


      else
        err -> err
      end
    end
  end

  @doc """
  Updates a preview.

  ## Examples

      iex> update_preview(preview, %{field: new_value})
      {:ok, %Preview{}}

      iex> update_preview(preview, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_preview(%Preview{} = preview, attrs) do
    preview
    |> Preview.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a preview.

  ## Examples

      iex> delete_preview(preview)
      {:ok, %Preview{}}

      iex> delete_preview(preview)
      {:error, %Ecto.Changeset{}}

  """
  def delete_preview(%Preview{} = preview) do
    Repo.delete(preview)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking preview changes.

  ## Examples

      iex> change_preview(preview)
      %Ecto.Changeset{source: %Preview{}}

  """
  def change_preview(%Preview{} = preview) do
    Preview.changeset(preview, %{})
  end


end
