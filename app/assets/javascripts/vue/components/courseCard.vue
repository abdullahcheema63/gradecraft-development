<template>
  <div class="course_card" :class="user_card_class">
    <h4>
      <span>{{ currentCourses[0].number }} {{ currentCourses[0].name }}</span>
      <span>{{ currentCourses[0].term.name }} {{ currentCourses[0].term.year }}</span>
    </h4>

    <div class="course_status">
      <p>{{ currentCourses[0].role }}</p>
      <div v-if="currentCourses[0].role === 'Instructor'">
        <p :class="currentCourses[0].licensed" @click="toggleModalState">
          {{ currentCourses[0].licensed }}
        </p>
      </div>
    </div>

    <div class="overview bg-blue_2" v-if="is_staff">
      <h4>
        <a>Grading Status</a>
      </h4>
      <div>
        <p class="lining_figures">
          {{currentCourses[0].gradingStatus.ungraded}}
          <span>Ungraded</span>
        </p>
        <p class="lining_figures">
          {{currentCourses[0].gradingStatus.ready}}
          <span>Ready for release</span>
        </p>
        <p class="lining_figures">
          {{currentCourses[0].gradingStatus.resubmissions}}
          <span>Resubmissions</span>
        </p>
      </div>
    </div>

    <div class="overview bg-blue_2" v-else>
      <h4>Events &amp; Announcements</h4>
      <div>
        <p class="lining_figures">
            {{currentCourses[0].eventCount}}
            <span>Events this week</span>
        </p>
        <p class="lining_figures">
            {{currentCourses[0].announcementCount}}
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
      <div class="assignment" v-for="item in currentCourses[0].assignments">
        <div>
          <p>
            <a>{{item.name}}</a>
            <span>Due {{item.dueDate}}</span>
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

    <!-- <Modal :modalState="modalState" @close="toggleModalState">
      <template slot="heading">Set Course Status</template>
      <template slot="content">
        <h2>Set the status of {{ course.course_numb }} {{ course.course_name }} {{ course.course_sem }} {{ course.course_year }}</h2>
        <form>
          <div class="form_options">
            <input id="trialCourse_2" name="courseStatus_2" type="radio">
            <label for="trialCourse_2">Trial course</label>
          </div>
          <div class="form_options">
            <input checked="checked" id="licensedCourse_2" name="courseStatus_2" type="radio">
            <label for="licensedCourse_2">Licensed course</label>
          </div>
          <br>
            <button class="action" type="button">Update status</button>
            <button class="secondary close" type="button" @click="toggleModalState">Cancel</button>
          </form>
      </template>
    </Modal> -->
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'course-card',
  data() {return {hello: "hello"}},
  computed: {
    currentCourses(){
      return this.$store.getters.currentCourseMembership;
    },
    user_card_class() {
      return this.$store.getters.currentCourseMembership[0].role.toLowerCase();
    },
    is_staff() {
      return this.$store.getters.currentCourseMembership[0].role === 'Instructor' || this.$store.getters.currentCourseMembership[0].role === 'GSI';
    },
    is_licensed() {
      return this.$store.getters.currentCourseMembership.license
    }
  }
}
`</script>
