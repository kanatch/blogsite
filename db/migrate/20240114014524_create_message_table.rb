class CreateMessageTable < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.string :message
    end
  end
end
