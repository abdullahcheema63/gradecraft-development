<template>
  <div>
    <p>
      With your
      <b>licensed account,</b>
      you can explore all GradeCraft has to offer and <b>create licensed courses.</b> <br />
      Licensed courses have the ability to:
    </p>
    <ul>
      <li>Integrate with other tools (like Canvas or Moodle)</li>
      <li>Import or add other users (such as assistants and students)</li>
    </ul>
    <p>
      Your
      <b>{{license.license_type_name}} license</b>
      allows you
      <b>{{license.max_courses || "unlimited"}}</b>
      licensed courses.
    </p>
    <p>Your license: </p>
    <ul>
      <li>
        <b>Expires </b>
        {{license.expires}}
      </li>
      <li>
        Was created {{license.created_at}}
      </li>
      <li>
        Was last updated {{license.updated_at}}
      </li>
    </ul>

    <dt>License Type</dt>
    <dd>{{license.license_type_name}}</dd>
    <dt>Expired?</dt>
    <dd>{{license.is_expired ? "Yes" : "No"}}</dd>
    <dt>Expires</dt>
    <dd>{{license.expires}}</dd>
    <dt>Max Courses</dt>
    <dd>{{license.max_courses || "Unlimited"}}</dd>
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
