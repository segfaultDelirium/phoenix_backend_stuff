defmodule RealDealApiWeb.Auth.ErrorResponse.Unauthorized do
  defexception [message: "Unauthorized dude!", plug_status: 401]
end

defmodule RealDealApiWeb.Auth.ErrorResponse.Forbidden do
  defexception [message: "You do not have access to this resource dude.", plug_status: 403]
  
end
