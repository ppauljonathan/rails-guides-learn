class CreateJoinTablePeopleCars < ActiveRecord::Migration[7.0]
  def change
    create_join_table :people, :cars do |t|
      # t.index [:person_id, :car_id]
      # t.index [:car_id, :person_id]
    end

    # this is not joining of two tables but a table which can be used to link two tables
    # table is created as cars_people (alphabetical order)
    # we can add indexes to the columns in the order we like
  end
end
