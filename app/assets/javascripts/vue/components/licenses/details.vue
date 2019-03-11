<template>
  <div>
    <dt>License Type</dt>
    <dd>{{license.license_type_name}}</dd>
    <dt>Expired?</dt>
    <dd>{{license.is_expired ? "Yes" : "No"}}</dd>
    <dt>Expires</dt>
    <dd>{{license.expires}}</dd>
    <dt>Created</dt>
    <dd>{{license.created_at}}</dd>
    <dt>Updated</dt>
    <dd>{{license.updated_at}}</dd>
  </div>
</template>

<script lang="coffee">
```
module.exports = {
  props: {
    license: Object,
  },
}
```
</script>
