<template>
  <div class='course_box'>
    <div class="course_card" :class="user_card_class">
      <h4>
        <span>{{ course.number }} {{ course.name }}</span>
        <span>{{ course.term.name }} {{ course.term.year }}</span>
      </h4>

      <div class="course_status">
        <p>{{ course.role }}</p>
        <div v-if="course.role === 'Instructor'">
          <p :class="course.licensed" @click="toggleModalState">
            {{ course.licensed }}
          </p>
        </div>
      </div>

      <div class="overview bg-blue_2" v-if="is_staff">
        <h4>
          <a>Grading Status</a>
        </h4>
        <div>
          <p class="lining_figures">
            {{course.gradingStatus.ungraded}}
            <span>Ungraded</span>
          </p>
          <p class="lining_figures">
            {{course.gradingStatus.ready}}
            <span>Ready for release</span>
          </p>
          <p class="lining_figures">
            {{course.gradingStatus.resubmissions}}
            <span>Resubmissions</span>
          </p>
        </div>
      </div>

      <div class="overview bg-blue_2" v-else>
        <h4>Events &amp; Announcements</h4>
        <div>
          <p class="lining_figures">
              {{course.eventCount}}
              <span>Events this week</span>
          </p>
          <p class="lining_figures">
              {{course.announcementCount}}
              <span>Unread announcements</span>
          </p>
        </div>
      </div>

      <div class="course_assignments">
        <h4>Upcoming Assignments</h4>
        <legend v-if="is_staff">
          <p>Planned</p>
          <p>Submitted</p>
        </legend>
        <div class="assignment" v-for="item in course.assignments">
          <div>
            <p>
              <a>{{item.name}}</a>
              <span v-if="item.dueDate">Due {{item.dueDate}}</span>
            </p>
          </div>
          <div v-if="is_staff">
            <p>{{item.planned}}</p>
            <p>{{item.submitted}}</p>
          </div>
          <div v-else>
            <p :class="item.graded">
              {{item.graded}}
            </p>
          </div>
        </div>
      </div>

      <div>
        <a class="button next">View course</a>
      </div>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'course-card',
  props: ['course'],
  data() {return {hello: "hello"}},
  computed: {
    user_card_class() {
      return this.course.role.toLowerCase();
    },
    is_staff() {
      return this.course.role === 'Instructor' || this.course.role === 'GSI';
    },
    is_licensed() {
      return this.course.license
    }
  }
}
`</script>
