// Mendix Studio Pro property panel configuration
// Defines getProperties, check, getPreview, etc.

// External types (JS objects passed by Mendix)
pub type Values

pub type Properties

pub type Target

/// Property panel configuration - controls widget property visibility in Studio Pro
pub fn get_properties(
  _values: Values,
  default_properties: Properties,
  _target: Target,
) -> Properties {
  default_properties
}
