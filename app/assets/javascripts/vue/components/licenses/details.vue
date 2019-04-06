<template>
  <div>
    <dt>License Type</dt>
    <dd>{{license.license_type_name}}</dd>
    <dt>Expired?</dt>
    <dd>{{license.is_expired ? "Yes" : "No"}}</dd>
    <dt>Expires</dt>
    <dd>{{license.expires}}</dd>
    <dt>Max Courses</dt>
    <dd>{{license.max_courses}}</dd>
    <dt>Created</dt>
    <dd>{{license.created_at}}</dd>
    <dt>Updated</dt>
    <dd>{{license.updated_at}}</dd>
  </div>
</template>

<script lang="coffee">
```
module.exports = {
  name: "licenses-details",
  props: {
    license: Object,
  },
}
```
</script>
