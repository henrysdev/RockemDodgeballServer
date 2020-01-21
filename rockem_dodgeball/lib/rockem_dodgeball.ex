defmodule RockemDodgeball do
  def main do
    AppSupervisor.start_link()
  end
end
