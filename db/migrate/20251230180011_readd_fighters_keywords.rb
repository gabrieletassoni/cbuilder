class ReaddFightersKeywords < ActiveRecord::Migration[7.2]
  def change
    create_join_table :fighters, :keywords do |t|
      t.index [:fighter_id, :keyword_id], unique: true
    end
  end
end
