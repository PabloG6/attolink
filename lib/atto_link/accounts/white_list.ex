import EctoEnum
defenum(OriginType, :type, [:ipv4, :ipv6, :url])
defmodule AttoLink.Accounts.WhiteList do
  use Ecto.Schema
  import Ecto.Changeset
  alias AttoLink.Accounts

  schema "whitelist" do
    field :ip_address, :string
    field :type, OriginType, default: :ipv4
    belongs_to :user, Accounts.User, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(white_list, attrs) do
    white_list
    |> cast(attrs, [:user_id, :type, :ip_address])
    |> validate_required([:user_id, :ip_address, :type])
    |> validate_type(attrs)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:ip_address, name: :whitelist_ip_address_user_index)
  end


  defp validate_type(%Ecto.Changeset{changes: %{ip_address: ip_address}} = changeset, %{type: :ipv4} = _attrs) do

    with true <- String.match?(ip_address, ~r/((?:\d+\.){3}(?:\d+)(?::\d*)?)/) do
        changeset
      else
        false ->
        add_error(changeset, :type, "Format of origin type doesn't match actual origin. url")
      end
  end
  defp validate_type(%Ecto.Changeset{changes: %{ip_address: ip_address}} = changeset, %{type: :url} = _attrs) do
    with true <- String.match?(ip_address, ~r/^(https?:\/\/)?([\da-z\.-]+\.[a-z\.]{2,6}|[\d\.]+)([\/:?=&#]{1}[\da-z\.-]+)*[\/\?]?$/) do
        changeset
      else
        false ->
          add_error(changeset, :type, "Input doesn't match the origin type you've selected.")
      end
  end

  defp validate_type(changeset, _attrs) do
    changeset
  end




end
