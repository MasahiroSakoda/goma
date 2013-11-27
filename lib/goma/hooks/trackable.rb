Warden::Manager.after_set_user only: :set_user do |record, warden, options|
  if warden.authenticated?(options[:scope]) && !warden.request.env['goma.skip_trackable']
    record.update_tracked_fields!(warden.request)
  end
end
