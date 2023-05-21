components {
  id: "script"
  component: "/rendercam/camera.script"
  position {
    x: 0.0
    y: 0.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
  properties {
    id: "nearZ"
    value: "-100.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "farZ"
    value: "100.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "useViewArea"
    value: "true"
    type: PROPERTY_TYPE_BOOLEAN
  }
  properties {
    id: "viewArea"
    value: "900.0, 900.0, 0.0"
    type: PROPERTY_TYPE_VECTOR3
  }
  properties {
    id: "fixedArea"
    value: "false"
    type: PROPERTY_TYPE_BOOLEAN
  }
  properties {
    id: "fixedHeight"
    value: "true"
    type: PROPERTY_TYPE_BOOLEAN
  }
}
