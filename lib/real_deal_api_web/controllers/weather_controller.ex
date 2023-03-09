defmodule RealDealApiWeb.WeatherController do
  use RealDealApiWeb, :controller

  def get_sample_weather(conn, _params) do
    text conn, "the weather is going to be f-ck up" 
  end
  
end
