class ChangeTableProducts < ActiveRecord::Migration[7.0]
  def change
    change_table :products do |t|
      t.remove :description, :name
      t.string :part_number
      t.index :part_number
      t.rename :upcode, :upc_code
    end
  end
end


# Below are some of the actions that change supports:
# add_column
# add_foreign_key
# add_index
# add_reference
# add_timestamps
# change_column_comment (must supply a :from and :to option)
# change_column_default (must supply a :from and :to option)
# change_column_null
# change_table_comment (must supply a :from and :to option)
# create_join_table
# create_table
# disable_extension
# drop_join_table
# drop_table (must supply a block)
# enable_extension
# remove_column (must supply a type)
# remove_foreign_key (must supply a second table)
# remove_index
# remove_reference
# remove_timestamps
# rename_column
# rename_index
# rename_table
# change_table is also reversible, as long as the block does not call change, change_default or remove.





# 6:32
# remove_column is reversible if you supply the column type as the third argument. Provide the original column options too, otherwise Rails can't recreate the column exactly when rolling back: