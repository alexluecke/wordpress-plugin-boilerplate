<?php
/*
Plugin Name: PluginClassName
Plugin URI:
Description:
Version:     0.1
Author:
Author URI:
License:     GPL2
License URI: https://www.gnu.org/licenses/gpl-2.0.html
Domain Path: /languages
Text Domain:
 */

// If this file is called directly, abort.
if (!defined('WPINC'))
	die;

// Don't load if not admin
if (!is_admin()) return;

$includes = array();
$includes[] = __DIR__."/includes/PLUGIN-NAME-activator.php";
$includes[] = __DIR__."/includes/PLUGIN-NAME-deactivator.php";

foreach ($includes as $include)
	if (file_exists($include)) require_once($include);

register_activation_hook(__FILE__, 'PluginClassNameActivator::activate');
register_deactivation_hook(__FILE__, 'PluginClassNameDeactivator::deactivate');

class PluginClassName {

	private static $_instance;

	private $_prefix = 'plugin-prefix';
	private $_name   = 'plugin_options';
	private $_title  = 'Plugin Options Title';
	private $_page   = __FILE__;

	/*
	 * Get singleton instance of the class
	 */
	public static function getInstance() {
		if (static::$_instance === NULL)
			static::$_instance = new static();
		return static::$_instance;
	}

	/**
	 * Register all admin hooks in the class constructor
	 */
	function __construct( ) {
		add_action('admin_menu', array(&$this, 'options_page') );
		add_action('admin_init', array(&$this, 'register_and_build_fields') );
		add_action('admin_init', array(&$this, 'add_settings_sections') );
		add_action('admin_init', array(&$this, 'add_settings_fields') );
	}

	/*
	 * Prefix is used to make fields unique
	 */
	function add_prefix($str) {
		return ($str) ? $this->_prefix . '-' . $str : '';
	}

	function get_opt($opt_name) {
		$options = get_option($this->_name);
		return isset($options[$this->add_prefix($opt_name)])
			? $options[$this->add_prefix($opt_name)] : '';
	}

	function section_callback() {
		// Nothing here.
	}

	function add_settings_sections() {
		add_settings_section(
			'main_section',
			'Main Settings',
			array(&$this, 'section_callback'),
			$this->_page
		);
	}

	function add_settings_fields() {
		add_settings_field(
			$this->add_prefix('upload_dir'),
			'Upload dir:',
			array( &$this, 'field_upload_dir_cb' ),
			$this->_page, // Option needs to be a unique string
			'main_section'
		);
	}

	/**
	 * Field callback functions
	 */
	function field_upload_dir_cb() {
		$value = $this->get_opt('upload_dir');
		echo "<input name=\"{$this->add_prefix('upload_dir')}\""
			. " type=\"text\""
			. " value=\"{$value}\" />";
	}

	/**
	 * Registers the settings link in LHS settings section
	 */
	function options_page() {
		add_options_page($this->_title,
			$this->_title,
			'administrator',
			$this->_page,
			array( &$this, 'options_html' )
		);
	}

	/*
	 * Print the admin form data
	 */
	function options_html() {
		// Start HTML // ?>
		<div id="<?php $this->add_prefix('options'); ?>">
			<h2><?php echo $this->_title; ?></h2>
			<p>Change the directory for PDF uploads.</p>
			<form method="post" action="options.php">
				<?php settings_fields($this->_name); ?>
				<?php do_settings_sections($this->_page); ?>
				<p class="submit">
				<input name="Submit"
					type="submit"
					class="button-primary"
					value="<?php esc_attr_e('Save Changes'); ?>" />
				</p>
			</form>
		</div>
		<?php // End HTML //
	}

	function validate_setting($options) {
		$options = get_option($this->_name);
		$p_keys = array_keys($_POST);
		$o_keys = array_keys($options);
		foreach ($p_keys as $pk)
			$options[$pk] = sanitize_text_field($_POST[$pk]);
		return $options;
	}

	function register_and_build_fields() {
		register_setting(
			$this->_name,
			$this->_name,
			array( &$this, 'validate_setting')
		);
	}

	function pre_upload($file){
		add_filter('upload_dir', array(&$this, 'change_pdf_upload_dir'));
		return $file;
	}

	function post_upload($fileinfo){
		remove_filter('upload_dir', array(&$this, 'change_pdf_upload_dir'));
		return $fileinfo;
	}

}

PluginClassName::getInstance(); // Create instance to fire the constructor to register hooks.
