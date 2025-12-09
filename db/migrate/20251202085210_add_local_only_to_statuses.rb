class AddLocalOnlyToStatuses < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:statuses, :local_only)
      add_column :statuses, :local_only, :boolean, default: false
    end
  end
end
