class EnvironmentsConfiguration < BaseConfiguration
  def initialize(params)
    @params = params
  end

  def save(output_dir)
    environments.each do |env|
      env_params = { rails_env: env }.merge(@params[env.to_sym])

      env_path = File.join(output_dir, env)
      FileUtils.mkdir_p env_path

      process_recursive(File.join(output_dir, 'environment'), '', env_path) do |source_path, target_path|
        if File.extname(source_path) == Templates::EXT && File.basename(source_path)[0] != '_'
          target_path.gsub!('.erb', '')
          render(source_path, target_path.gsub('.erb', ''), env_params)
        end
      end

      env_config_path = File.join output_dir, 'ansible/group_vars', env
      FileUtils.mkdir_p env_config_path

      render(File.join(output_dir, 'environment', '_config.yml.erb'),
             File.join(env_config_path, 'config.yml'),
             env: env_params)
    end
  end

  private

  def process_file?(file)
    true
  end

  def environments
    %w(development staging production) & @params.keys.map(&:to_s)
  end
end
