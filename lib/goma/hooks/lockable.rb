Warden::Manager.after_set_user only: :set_user do |record, warden, options|
  if record.lockable? &&
     record.goma_config.lock_strategy == :failed_attempts &&
     record.send(record.goma_config.failed_attempts_getter) > 0
    record.update_attribute(record.goma_config.failed_attempts_attribute_name, 0)
  end
end
