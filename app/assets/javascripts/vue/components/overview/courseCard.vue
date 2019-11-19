<template>
  <div v-if="status=='published'" class="course_card" :class="[user_card_class, paid_course_class, paid_by_another, created_by_another]">
    <h4 :title="course.name">
      <span>{{ course.number }} {{ course.name }}</span>
      <span>{{ course.term.name }} {{ course.term.year }}</span>
    </h4>

    <div class="course_status">
      <p>{{ user_card_class }}</p>
      <div v-if="course.role === 'professor' && paid_course_class">
        <p>Subscribed</p>
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
      <div v-if="course.assignments[0]">
        <div class="assignment" v-for="assignment in course.assignments">
          <div>
            <p>
              <a>{{assignment.name}}</a>
              <span v-if="assignment.due_at">Due {{formatDate(assignment.due_at)}}</span>
            </p>
          </div>
          <div v-if="is_staff">
            <p>{{assignment.planned}}</p>
            <p>{{assignment.submitted}}</p>
          </div>
          <div v-else>
            <p :class="assignment_status(assignment)">
              {{assignment_status(assignment)}}
            </p>
          </div>
        </div>
      </div>
      <div class="empty" v-else>
        <p v-if="is_staff"><em>There aren’t any assignments coming up for this course</em></p>
        <p v-else><em>You don’t have any assignments coming up for this course</em></p>
      </div>
    </div>

    <div class="button_box">
      <a class="button next" v-bind:href="course.url">View course</a>
      <dropdownDotsComponent v-if="is_instructor">
        <template slot="content">
          <ul>
            <li>
              <a @click="$emit('copyCourseForm', course)">Copy</a>
            </li>
            <li>
              <a @click="$emit('unpublishCourseModal',course)">Unpublish</a>
            </li>
            <li>
              <a @click="$emit('archiveCourseModal', course)">Archive</a>
            </li>
            <li>
              <a @click="$emit('deleteCourseModal', course)">Delete</a>
            </li>
          </ul>
        </template>
      </dropdownDotsComponent>
    </div>
  </div>

  <div v-else-if="status=='unpublished'" class="course_card" :class="[user_card_class, paid_course_class, paid_by_another, created_by_another]">
    <h4>
      <span>{{ course.number }} {{ course.name }}</span>
      <span>{{ course.term.name }} {{ course.term.year }}</span>
    </h4>

    <div class="course_status">
      <p>{{user_card_class}}</p>
      <div v-if="course.role === 'professor' && paid_course_class">
        <p>Subscribed</p>
      </div>
    </div>

    <div class="bg-blue_2" v-if="!is_staff">
      <h4>
        Under Construction!
      </h4>
      <p>
        Your instructor is working on this course right now. Please check back later.
      </p>
    </div>

    <div class="button_box">
      <a class="button next" :href="course.url" v-if="is_staff">View course</a>
      <button type="button" disabled="disabled" class="next" v-if="!is_staff">View course</button>

      <dropdownDotsComponent v-if="is_instructor">
        <template slot="content">
          <ul>
            <li>
              <a @click="$emit('copyCourseForm', course)">Copy</a>
            </li>
            <li v-if="course.subscribed">
              <a @click="$emit('publishCourseModal', course)">Publish</a>
            </li>
            <li>
              <a @click="$emit('archiveCourseModal', course)">Archive</a>
            </li>
            <li>
              <a @click="$emit('deleteCourseModal', course)">Delete</a>
            </li>
          </ul>
        </template>
      </dropdownDotsComponent>
    </div>
  </div>

  <div v-else-if="status=='past'" class="course_card past" :class="[user_card_class, paid_course_class, paid_by_another, created_by_another]">
    <h4>
      <span>{{ course.number }} {{ course.name }}</span>
      <span>{{ course.term.name }} {{ course.term.year }}</span>
    </h4>

    <div class="course_status">
      <p>{{course.role}}</p>
      <div>
        <p :class="'subscribed'" v-if="is_subscribed">
          Was Subscribed
        </p>
      </div>
    </div>

    <div>
      <a class="button next" v-bind:href="course.url">View course</a>
    </div>
  </div>
  <div v-else-if="status=='archived'" class="course_card archived" :class="[user_card_class, paid_course_class, paid_by_another, created_by_another, hidden_from_students, request_pending]">
    <h4>
      <span>{{ course.number }} {{ course.name }}</span>
      <span>{{ course.term.name }} {{ course.term.year }}</span>
    </h4>

    <div class="course_status">
      <p>{{course.role}}</p>
      <div>
        <p :class="'subscribed'" v-if="is_subscribed">
          Was subscribed
        </p>
      </div>
    </div>

    <div class="button_box">
      <a class="button next" v-bind:href="course.url">View course</a>

      <dropdownDotsComponent v-if="is_instructor">
        <template slot="content">
          <ul>
            <li>
              <a @click="$emit('copyCourseForm', course)">Copy</a>
            </li>
            <li v-if="course.published">
              <a @click="$emit('unpublishCourseModal',course)">Hide</a>
            </li>
            <li v-if="!course.published">
              <a @click="$emit('publishCourseModal', course)">Show</a>
            </li>
            <li>
              <a @click="$emit('deleteCourseModal', course)">Delete</a>
            </li>
          </ul>
        </template>
      </dropdownDotsComponent>

    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'courseCard',
  props: ['course', 'status'],
  components: {
    dropdownDotsComponent: () => VComponents.get('vue/components/structure/dropdownDotsComponent'),
    buttonModal: () => VComponents.get('vue/components/structure/buttonModal'),
  },
  data() {
    return {
      copyingCourse: false,
      deletingCourse: false,
    }
  },
  computed: {
    is_staff() {
      return this.course.role === 'professor' || this.course.role === 'gsi';
    },
    is_instructor() {
      return this.course.role === 'professor';
    },
    is_gsi() {
      return this.course.role === 'gsi';
    },
    user_card_class() {
      if( this.is_instructor ){ return 'Instructor' }
      else if (this.is_gsi){ return 'GSI' }
      else { return 'Student'}
    },
    paid_course_class() {
      if( this.course.subscribed ){ return 'paid' }
    },
    paid_by_another() {
      if( this.course.paidByAnotherUser ){ return 'another_user_paid' }
    },
    created_by_another() {
      if( this.course.createdByAnotherUser ){ return 'another_user_created' }
    },
    hidden_from_students() {
      if( !this.course.published ){ return 'hidden_from_students' }
    },
    request_pending() {
      if( this.course.requestPending ){ return 'request_pending' }
    },
    is_subscribed() {
      return this.course.subscribed
    }
  },
  methods: {
    formatDate(date){
      return moment(String(date)).format('LLLL')
    },
    assignment_status(assignment){
      if (assignment.graded){ return "graded" }
      if (assignment.submitted){ return "submitted" }
      if (assignment.planned){ return "planned" }
    },
    copyCourse(courseID){
      this.copyingCourse = true
      this.$store.dispatch('copyCourse', courseID)
    },
    unpublishCourse(courseID){
      this.$store.dispatch('unpublishCourse', courseID)
    },
    publishCourse(courseID){
      this.$store.dispatch('publishCourse', courseID)
    },
    archiveCourse(courseID){
      this.$store.dispatch('archiveCourse', courseID)
    },
    deleteCourse(courseID){
      this.deletingCourse = true
      this.$store.dispatch('deleteCourse', courseID)
    }
  }
}
`</script>
