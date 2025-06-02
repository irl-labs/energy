component_schema = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Energy Component Metadata",
  "description": "Schema for ERC-1155 metadata files for solar modules, inverters, batteries, etc.",
  "type": "object",
  "required": ["name", "description", "image", "attributes", "component_type", "tokenId"],
  "properties": {
    "name": { "type": "string" },
    "description": { "type": "string" },
    "image": { "type": "string", "format": "uri" },
    "data_sheet": { "type": "string", "format": "uri" },
    "component_type": {
      "type": "string",
      "enum": ["module", "inverter", "battery", "meter", "ess"]
    },
    "tokenId": { "type": "string" },
    "attributes": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["trait_type", "value"],
        "properties": {
          "trait_type": { "type": "string" },
          "value": {}
        }
      }
    }
  }
}
