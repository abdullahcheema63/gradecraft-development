class LicensesController < ApplicationController
  def new
    @license = License.new
  end
end
