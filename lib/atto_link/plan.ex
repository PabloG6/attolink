defmodule AttoLink.Atto.Plan do

  defstruct preview_limit: nil, storage_limit: nil, request_limit: nil, request_overage: nil, price: nil
  @type t() :: %AttoLink.Atto.Plan{preview_limit: integer, storage_limit: integer, request_limit: integer, request_overage: float, price: float}

  def plan_type(:free) do
    %AttoLink.Atto.Plan{preview_limit: 100, storage_limit: 104_857_600, request_limit: 500, request_overage: :none, price: 0}
  end

  def plan_type(:basic) do
    %AttoLink.Atto.Plan{preview_limit: 1500, storage_limit: 3_221_225_472, request_limit: 4000, request_overage: 0.06, price: 7.00}

  end

  @doc """
  1500 requests per hour -> 540 megabytes a month maximum
  storage_limit 16 gib -> 0.02 * 16 -> 32 cents a month
  request_limit: 7000 requests at 3.5 megabytes -> 24.5 gigabytes -> 14 cents

  """
  def plan_type(:premium) do
    %AttoLink.Atto.Plan{preview_limit: 7500, storage_limit: 16_106_127_360, request_limit:  20000, request_overage: 0.04, price: 25}
  end



end
