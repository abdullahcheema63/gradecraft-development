<template>
  <div>
    <alertComponent></alertComponent>
    <div class="content_block intro">
      <h1>My Dashboard</h1>
      <guideMessage>
        <p>
          Welcome <span v-if="hasSeenOnboarding">back</span> to your GradeCraft dashboard, {{ userFirstName }}!
        </p>
        <p>
          I’m here to help you as you set up your courses. Look for my messages if you want some tips on how to use GradeCraft features!
          You can also
          <a @click="showOnboardingModal();">review our onboarding slides</a>
          at any time or visit <a href="https://www.gamefulpedagogy.com/" target="_blank">GamefulPedagogy.com</a> for ideas on how to build your courses more gamefully.
        </p>
      </guideMessage>

      <modalComponent v-if="onboarding && showOnboarding" :modalState="modalState" @close="toggleModalState(); sawOnboarding();" class="component_container onboarding">
        <template slot="heading">Welcome to GradeCraft!</template>
        <template slot="content">
          <vue-slick class="onboarding_slides" :options="slickOptions">
            <div class="slides instructor_1">
              <div></div>
              <div>
                <h2>Hey there, {{userFirstName}}!</h2>
                <p>
                  Welcome to GradeCraft! GradeCraft lets you build courses with gameful features such as:
                </p>
                <ul class="pink_dots">
                  <li>Offering students choices about their work</li>
                  <li>Tools to help provide rapid and thorough feedback</li>
                  <li>Playful elements like badges, unlocks, and leaderboards</li>
                  <li>Transparent student-facing analytics</li>
                </ul>
              </div>
            </div>
            <div class="slides instructor_2">
              <div></div>
              <div>
                <h2>Support for student autonomy</h2>
                <p>
                  The Points Planner promotes student agency by enabling students to make choices and set goals.
                </p>
              </div>
            </div>
            <div class="slides instructor_3">
              <div></div>
              <div>
                <h2>Paths to recognize accomplishments</h2>
                <p>
                  Unlocks let you guide students down a path towards mastery by connecting assignments together.
                </p>
                <p>
                  Badges allow you to recognize students’ efforts when they reach milestones.
                </p>
              </div>
            </div>
            <div class="slides instructor_4">
              <div></div>
              <div>
                <h2>Easy flexible grading</h2>
                <p>
                  You can grade using levels, points, rubrics, or a binary “met/not met” scheme.
                </p>
                <p>
                  Quickly identify assignments that need to be graded and share feedback with your students. Or, let them grade themselves by following your guidelines.
                </p>
              </div>
            </div>
            <div class="slides instructor_5">
              <div></div>
              <div>
                <h2>Informative analytics</h2>
                <p>
                  Easily keep track of what students are completing in your course and what competency level they’ve reached.
                </p>
                <h3>Ready to go?</h3>
                <button @click="toggleModalState" type="button" class="action" style="margin-top: 0.75em;">Let’s get started!</button>
              </div>
            </div>
          </vue-slick>

        </template>
        <template slot="cancel-link"> &nbsp; </template>
      </modalComponent>

    </div>

    <tabContainer>
      <template slot="tabBarNav">
        <div v-for="option in tabBarOption">
          <input type="radio" :id="option" :value="option" v-model="tabSection[0]" name="tab_group_1" />
          <label :for="option">{{option}}</label>
        </div>
      </template>
      <template slot="tabSections">
        <div v-if="tabSection[0]==='Current'">
          <div class="content_block">
            <div class="p_button">
              <p>
                This section has all your current courses, including those that other instructors or course managers may share with you. You can add a new course and publish or unpublish courses at any time.
              </p>
              <buttonModal button_class="action" ref="buttonModal_add">
                <template slot="button-text">Add a course</template>
                <template slot="heading">Add a course</template>
                <template v-if="addingCourse" slot="content" >
                  <div class="yeti-loading_spin">
                    <div></div>
                    <h4>Your course is being added!</h4>
                  </div>
                </template>
                <template v-else slot="content">
                  <h2>Let’s add a new course!</h2>
                  <h4>Essential Course Info</h4>
                  <form>
                    <div v-if="newCourseErrors" class="inline_alert_msg">
                      <p>
                        Please fill out the <b>required fields</b> below if you want to create a new course.
                      </p>
                    </div>
                    <div class="flex-2 form_pair">
                      <div class="form_elem">
                        <input type="text" v-model="newCourse.number" id="course_number" required="required" placeholder="Your course number" />
                        <label for="course_number">Course #</label>
                      </div>
                      <div class="form_elem">
                        <input type="text" v-model="newCourse.name" id="course_name" required="required" placeholder="Your course name" />
                        <label for="course_name">Course name</label>
                      </div>
                      <div class="form_elem">
                        <flat-pickr v-model="newCourse.term.start" :config="config" placeholder="Course start date" id="course_start" class="calendar" autocomplete="off"></flat-pickr>
                        <label for="course_start">Course start date</label>
                      </div>
                      <div class="form_elem">
                        <flat-pickr v-model="newCourse.term.end" :config="config" placeholder="Course end date" id="course_end" class="calendar" autocomplete="off"></flat-pickr>
                        <label for="course_end">Course end date</label>
                      </div>

                      <div class="form_elem">
                        <select id="course_semester" v-model="newCourse.term.name">
                          <option value="" selected="selected" disabled="disabled">Semester</option>
                          <option :value="'Fall'">Fall</option>
                          <option :value="'Winter'">Winter</option>
                          <option :value="'Spring'">Spring</option>
                          <option :value="'Summer'">Summer</option>
                        </select>
                        <label for="course_semester">Semester</label>
                      </div>
                      <div class="form_elem">
                        <select id="course_year" v-model="newCourse.term.year">
                          <option value="" selected="selected" disabled="disabled">Year</option>
                          <option :value="2020">2020</option>
                          <option :value="2019">2019</option>
                          <option :value="2018">2018</option>
                          <option :value="2017">2017</option>
                        </select>
                        <label for="course_year">Year</label>
                      </div>
                    </div>

                    <button class="action" type="button" @click.prevent="addCourse()">Add course</button>
                  </form>
                </template>
              </buttonModal>
            </div>
          </div>

          <accordionComponent accordion_content="bg-grey_barely" :open_default="true">
            <template slot="heading">Published Courses</template>
            <template slot="content">
              <p class="unspace-bottom">
                <br />
                Published courses are visible to students, observers,
                {{environmentName}}, and instructors added to each course.
              </p>
              <div class="course_box" v-if="publishedCourses.length">
                <courseCard v-for="course in publishedCourses" :key="course.id" :course="course" status="published"
                v-on:copyCourseForm='openCopyCourseForm($event)' v-on:deleteCourseModal='openDeleteCourseModal($event)'
                v-on:archiveCourseModal='openArchiveCourseModal($event)' v-on:unpublishCourseModal='openUnpublishCourseModal($event)'></courseCard>
              </div>

              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>You don’t have any published courses right now!</em></p>
                </div>
              </div>
            </template>
          </accordionComponent>

          <accordionComponent accordion_content="bg-grey_barely" :open_default="true">
            <template slot="heading">Unpublished Courses</template>
            <template slot="content">
              <p class="unspace-bottom">
                <br />
                Unpublished courses are hidden from students and observers, but can be seen and edited by
                {{environmentName}} and instructors.
              </p>
              <div v-if="unpublishedCourses.length">
                <div class="course_box" v-if="unpublishedCourses.length">
                  <courseCard v-for="course in unpublishedCourses" :key="course.id" :course="course" status="unpublished"
                  v-on:copyCourseForm='openCopyCourseForm($event)' v-on:deleteCourseModal='openDeleteCourseModal($event)'
                  v-on:archiveCourseModal='openArchiveCourseModal($event)' v-on:publishCourseModal='openPublishCourseModal($event)'></courseCard>
                </div>
              </div>
              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>You don’t have any unpublished courses right now!</em></p>
                </div>
              </div>
            </template>
          </accordionComponent>
        </div>

        <div v-if="tabSection[0]==='Archived'">
          <div class="content_block">
            <p>
              Your archive includes any course in which you had a role of instructor.
            </p>
            <ul class="pink_dots">
              <li>
                <b>You can’t make changes to archived courses. </b>
              </li>
              <li>
                If you like how a course was set up and want to re-use it, you can copy it.
              </li>
              <li>
                If you need to unarchive a course, please email us at <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>
              </li>
            </ul>
            <div v-if="archivedCourses.length">
              <div class="table_functions">
                <div class="filter_box">
                  <p><strong>Select which filters you want to apply:</strong></p>
                  <div>
                    <span v-for="year in courseTermYear" :key="year" v-if="year.length > 0">
                      <input :id="year" type="checkbox" v-model="termYear" :value="year"/>
                      <label :for="year">{{year}}</label>
                    </span>
                  </div>
                  <div>
                    <span v-for="term in courseTermName" :key="term" v-if="term.length > 0">
                      <input :id="term" type="checkbox" v-model="termName" :value="term"/>
                      <label :for="term">{{term}}</label>
                    </span>
                  </div>
                </div>
                <div class="search_box">
                  <div class="form_elem">
                    <input type="search" v-model="searchArchivedCourses" id="searchArchivedCourses" placeholder="Search archived courses">
                    <label for="searchArchivedCourses">Search courses</label>
                  </div>
                </div>
              </div>

              <div class="course_box" v-if="filteredArchivedCourses.length">
                <courseCard v-for="course in filteredArchivedCourses" :key="course.id" :course="course" status="archived"
                v-on:copyCourseForm='openCopyCourseForm($event)' v-on:deleteCourseModal='openDeleteCourseModal($event)'
                v-on:publishCourseModal='openPublishCourseModal($event)' v-on:unpublishCourseModal='openUnpublishCourseModal($event)'></courseCard>
              </div>
              <div class="course_box" v-else>
                <div class="course_card empty">
                  <p><em>Sorry, there are no matching search results!</em></p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <modalComponent v-if="copyCourseForm" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading">Copy a course</template>
          <template slot="content" v-if="copyingCourse">
            <div class="yeti-loading_spin">
              <div></div>
              <h4>Your course is copying!</h4>
            </div>
          </template>
          <template slot="content" v-else>
            <h2>You’re about to copy:
              <br />
              <span class="pink_text">
                {{this.selectedCourse.number}} {{this.selectedCourse.name}}<span v-if="selectedCourse.term.name || selectedCourse.term.year">, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}</span>.
              </span>
            </h2>
            <h4>Essential Course Info</h4>
            <p>
              You can update this info now or do so later:
            </p>
            <div v-if="copyCourseErrors"  class="inline_alert_msg">
              <p>
                Please fill out the <b>required fields</b> below if you want to copy your course.
              </p>
            </div>
            <div class="flex-2 form_pair">
              <div class="form_elem">
                <input type="text" v-model="newCopiedCourse.number" id="course_number" required="required" placeholder="Your course number" />
                <label for="course_number">Course #</label>
              </div>
              <div class="form_elem">
                <input type="text" v-model="newCopiedCourse.name" id="course_name" required="required" placeholder="Your course name" />
                <label for="course_name">Course name</label>
              </div>
              <div class="form_elem">
                <flat-pickr v-model="newCopiedCourse.term.start" :config="config" placeholder="Course start date" id="course_start" class="calendar" autocomplete="off"></flat-pickr>
                <label for="course_start">Course start date</label>
              </div>
              <div class="form_elem">
                <flat-pickr v-model="newCopiedCourse.term.end" :config="config" placeholder="Course end date" id="course_end" class="calendar" autocomplete="off"></flat-pickr>
                <label for="course_end">Course end date</label>
              </div>

              <div class="form_elem">
                <select id="course_semester" v-model="newCopiedCourse.term.name">
                  <option value="" selected="selected" disabled="disabled">Semester</option>
                  <option :value="'Fall'">Fall</option>
                  <option :value="'Winter'">Winter</option>
                  <option :value="'Spring'">Spring</option>
                  <option :value="'Summer'">Summer</option>
                </select>
                <label for="course_semester">Semester</label>
              </div>
              <div class="form_elem">
                <select id="course_year" v-model="newCopiedCourse.term.year">
                  <option value="" selected="selected" disabled="disabled">Year</option>
                  <option :value="2020">2020</option>
                  <option :value="2019">2019</option>
                  <option :value="2018">2018</option>
                  <option :value="2017">2017</option>
                </select>
                <label for="course_year">Year</label>
              </div>
            </div>
          </template>

          <template slot="submit-button" v-if="copyingCourse"> </template>
          <template slot="submit-button" v-else>
            <button type="button" class="action" style="margin-bottom: 1em;" @click="copyCourse(selectedCourse.id)">Copy</button>
            <br />
          </template>
          <template slot="cancel-link" v-if="copyingCourse"> &nbsp; </template>
        </modalComponent>

        <modalComponent v-if="deleteCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading">Delete Course Confirmation</template>
          <template slot="content" v-if="deletingCourse">
            <div class="yeti-loading_spin">
              <div></div>
              <h4>Your course is deleting! (Goodbyyyeee)</h4>
            </div>
          </template>
          <template slot="content" v-else>
            <div class="inline_alert_msg" v-if="deleteCourseError">
              <p>
                If you want to delete this course, you must type “DELETE” to confirm.
              </p>
            </div>
            <h2 class="pink_text">Are you sure you want to delete your course?</h2>
            <p>
              You’re about to delete
              <strong>
                {{this.selectedCourse.number}} {{this.selectedCourse.name}}<span v-if="selectedCourse.term.name || selectedCourse.term.year">, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}</span>.
              </strong>
            </p>
            <p>
              <strong>This cannot be undone.</strong>
              <br />
              Please type <strong>DELETE</strong> to confirm.
            </p>
            <div class="form_elem">
              <input type="text" id="course_deletion_confirmation" v-model="deleteConfirmation" required="required" placeholder="Type DELETE to confirm" />
              <label for="course_deletion_confirmation">Confirm Deletion</label>
            </div>
          </template>

          <template slot="submit-button" v-if="deletingCourse"> </template>
          <template slot="submit-button" v-else>
            <button type="button" class="action" style="margin-bottom: 1em;" @click="deleteCourse(selectedCourse.id)">Delete my course</button>
            <br />
          </template>
          <template slot="cancel-link" v-if="deletingCourse"> &nbsp; </template>
        </modalComponent>

        <modalComponent v-if="archiveCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading">Archive Course Confirmation</template>
          <template slot="content" v-if="archivingCourse">
            <div class="yeti-loading_spin">
              <div></div>
              <h4>Your course is archiving!</h4>
            </div>
          </template>
          <template slot="content" v-else>
            <h2>Please confirm you want to archive your course</h2>
            <p>
              You’re about to archive
              <strong>
                {{this.selectedCourse.number}} {{this.selectedCourse.name}}<span v-if="selectedCourse.term.name || selectedCourse.term.year">, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}</span>.
              </strong>
              <br />
              <strong>You will not be able to unarchive it</strong> without emailing us at <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>
            </p>
            <p>
              Archiving a course is useful when your term has ended and students are no longer active in GradeCraft.
            </p>
          </template>

          <template slot="submit-button" v-if="archivingCourse"> </template>
          <template slot="submit-button" v-else>
            <button type="button" class="action" style="margin-bottom: 1em;" @click="archiveCourse(selectedCourse.id)">Archive my course</button>
            <br />
          </template>
          <template slot="cancel-link" v-if="archivingCourse"> &nbsp; </template>
        </modalComponent>

        <modalComponent v-if="unpublishCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading" v-if="selectedCourse.active">Unpublish Course Confirmation</template>
          <template slot="heading" v-else>Hide Course Confirmation</template>

          <template slot="content" v-if="unpublishingCourse">
            <div class="yeti-loading_spin">
              <div></div>
              <h4 v-if="selectedCourse.active">Your course is unpublishing!</h4>
              <h4 v-else>Your course is going into hiding!</h4>
            </div>
          </template>
          <template slot="content" v-else-if="!selectedCourse.active">
            <h2>Please confirm you want to hide your course</h2>
            <p>
              You’re about to hide
              <strong>
                {{this.selectedCourse.number}} {{this.selectedCourse.name}}<span v-if="selectedCourse.term.name || selectedCourse.term.year">, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}</span>.
              </strong>
              <br />
              It will be <strong>hidden from students,
              {{environmentName}}, and observers</strong> in the course, but remain visible to any instructors in the course.
            </p>
            <p>
              Hiding a course is useful if you only want to allow course instructors to review the past content.
            </p>
          </template>
          <template slot="content" v-else>
            <h2>Please confirm you want to unpublish your course</h2>
            <p>
              You’re about to unpublish
              <strong>
                {{this.selectedCourse.number}} {{this.selectedCourse.name}}, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}.
              </strong>
            </p>
            <p>
              It will be <strong>hidden from students and observers</strong> in the course, but remain visible to and editable by any
              {{environmentName}} and instructors in the course.
            </p>

            <p>
              Unpublishing a course is useful if you need to make significant changes during a term and just need to make it temporarily invisible when students are active in GradeCraft.
            </p>

            <!-- <p style="background: yellow;">
              FUTURE DEV CYCLE
              To E from S: The following p-tag is v-if conditional, to show for users if they're the one paying for the selected course.
            </p> -->
            <p>
              Unpublishing a course <strong>does not remove it from your subscription.</strong> You can <a href="/subscriptions">manage your subscription</a> if you want to make this change.
            </p>
          </template>

          <template slot="submit-button" v-if="unpublishingCourse"> </template>
          <template slot="submit-button" v-else-if="!selectedCourse.active">
            <button type="button" class="action" style="margin-bottom: 1em;" @click="unpublishCourse(selectedCourse.id)">Hide my course</button>
            <br />
          </template>
          <template slot="submit-button" v-else>
            <button type="button" class="action" style="margin-bottom: 1em;" @click="unpublishCourse(selectedCourse.id)">Unpublish my course</button>
            <br />
          </template>
          <template slot="cancel-link" v-if="unpublishingCourse"> &nbsp; </template>
        </modalComponent>

        <modalComponent v-if="publishCourseModal" :modalState="modalState" @close="toggleModalState" class="component_container">
          <template slot="heading" v-if="selectedCourse.active">Publish Course Confirmation</template>
          <template slot="heading" v-else>Show Course Confirmation</template>

          <template slot="content" v-if="publishingCourse">
            <div class="yeti-loading_spin">
              <div></div>
              <h4 v-if="selectedCourse.active">Your course is publishing!
                <br />
                (So exciting)
              </h4>
              <h4 v-else>Your course is coming out of hiding!</h4>
            </div>
          </template>
          <template slot="content" v-else-if="selectedCourse.subscribed && selectedCourse.active">
            <h2>Please confirm you want to publish your course</h2>
            <p>
              You’re about to publish
              <strong>
                {{this.selectedCourse.number}} {{this.selectedCourse.name}}<span v-if="selectedCourse.term.name || selectedCourse.term.year">, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}</span>.
              </strong>
              <br />
              It will be <strong>visible to all users</strong> in the course, and remain editable by any
              {{environmentName}} and instructors in the course.
            </p>
          </template>
          <template slot="content" v-else-if="!selectedCourse.subscribed && selectedCourse.active">
            <h2>Oops, you can’t publish this course yet!</h2>
            <p>
              You’re trying to publish
              <strong>
                {{this.selectedCourse.number}} {{this.selectedCourse.name}}, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}},
              </strong>
              but this course has not been paid for.
            </p>
            <p>
              If you’d like to publish it, add this course to your GradeCraft subscription.
            </p>
          </template>
          <template slot="content" v-else>
            <h2>Please confirm you want to show your course</h2>
            <p>
              You’re about to show
              <strong>
                {{this.selectedCourse.number}} {{this.selectedCourse.name}}<span v-if="selectedCourse.term.name || selectedCourse.term.year">, {{this.selectedCourse.term.name}} {{this.selectedCourse.term.year}}</span>.
              </strong>
              <br />
              It will be <strong>visible to all users</strong> in the course, but remain uneditable by all.
            </p>
            <p>
              Showing a course is useful if you want to allow all your course users to review the past content.
            </p>
          </template>

          <template slot="submit-button" v-if="publishingCourse"> </template>
          <template slot="submit-button" v-else-if="selectedCourse.subscribed && selectedCourse.active">
            <button type="button" class="action" style="margin-bottom: 1em;" @click="publishCourse(selectedCourse.id)">Publish my course</button>
            <br />
          </template>
          <template slot="submit-button" v-else-if="!selectedCourse.subscribed && selectedCourse.active">
            <a class="button action next" style="margin-bottom: 1em;" href="/subscriptions">Go to my subsription</a>
            <br />
          </template>
          <template slot="submit-button" v-else>
            <button type="button" class="action" style="margin-bottom: 1em;" @click="publishCourse(selectedCourse.id)">Show my course</button>
            <br />
          </template>

          <template slot="cancel-link" v-if="publishingCourse"> &nbsp; </template>
        </modalComponent>
      </template>
    </tabContainer>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'instructor',
  mounted(){
    this.$root.$on('revertToDefault', data => {
      console.log("Triggered revertToDefault from mounted method in instructor component")
      this.revertToDefault()
    });
  },
  components: {
    alertComponent: () => VComponents.get('vue/components/structure/alertComponent'),
    courseCard: () => VComponents.get('vue/components/overview/courseCard'),
    accordionComponent: () => VComponents.get('vue/components/structure/accordionComponent'),
    buttonModal: () => VComponents.get('vue/components/structure/buttonModal'),
    modalComponent: () => VComponents.get('vue/components/structure/modalComponent'),
    tabContainer: () => VComponents.get('vue/components/structure/tabContainer'),
    guideMessage: () => VComponents.get('vue/components/structure/guideMessage'),
    VueFlatpickr,
    vueSlickCarousel
  },
  data() {
    return {
      showOnboarding: false,
      slickOptions: {
        dots: true,
        prevArrow: '<button class="slick-prev" aria-label="Previous" type="button"> </button>',
        nextArrow: '<button class="slick-next" aria-label="Next" type="button"> </button>',
      },
      tabBarOption: ["Current", "Archived"],
      tabSection: ["Current"],
      config: {
        allowInput: true,
        enableTime: true,
        dateFormat: "D, M d, Y at h:i K",
        static: true,
      },
      termYear: [],
      termName: [],
      searchArchivedCourses: "",
      newCourseErrors: false,
      newCourse: {
        name: "",
        number: "",
        role: "professor",
        term: {
          name: "",
          year: "",
          start: null,
          end: null
        },
      },
      copyCourseErrors: false,
      newCopiedCourse: {
        id: null,
        name: "",
        number: "",
        role: "professor",
        term: {
          name: "",
          year: "",
          start: null,
          end: null
        },
      },
      modalState: true,
      selectedCourse: {},
      addCourseModal: false,
      addingCourse: false,
      copyCourseForm: false,
      copyingCourse: false,
      deleteCourseModal: false,
      deletingCourse: false,
      deleteConfirmation: "",
      deleteCourseError: false,
      archiveCourseModal: false,
      archivingCourse: false,
      unpublishCourseModal: false,
      unpublishingCourse: false,
      publishCourseModal: false,
      publishingCourse: false,
    }
  },
  created: function() {
    this.$store.dispatch("getCourseMemberships");
  },
  computed: {
    currentCourses(){
      return this.$store.state.user.courseMembership.filter( course => {
        return course.active
      });
    },
    publishedCourses(){
      return this.currentCourses.filter( course => {
        return course.published
      });
    },
    unpublishedCourses(){
      return this.currentCourses.filter( course => {
        return !course.published
      });
    },
    archivedCourses(){
      return this.$store.state.user.courseMembership.filter( course => {
        return !course.active
      });
    },
    filteredArchivedCourses(){
      var allArchivedCourses = this.archivedCourses;

      return allArchivedCourses.filter(this.filterArchivedCourses)
    },
    courseTermYear(){
      return new Set(this.archivedCourses.map(courseMembership => courseMembership.term.year))
    },
    courseTermName(){
      return new Set(this.archivedCourses.map(courseMembership => courseMembership.term.name))
    },
    userFirstName(){
      return this.$store.state.user.firstName;
    },
    onboarding(){
      if(!this.hasSeenOnboarding){
        return true
      }
      else if(this.showOnboarding === false) {
        return false
      }
      else{
        return true
      }
    },
    hasSeenOnboarding(){
      return this.$store.getters.hasSeenOnboarding;
    },
    environmentName(){
      if (this.$store.state.user.environment === 'development'){return "teaching elves"}
      if (this.$store.state.user.environment === 'production'){return "GSIs"}
      if (this.$store.state.user.environment === 'beta'){return "teaching assistants"}
    },
  },
  methods: {
    filterArchivedCourses(course){
      if (this.searchArchivedCourses.length){
        var name = course.name.toLowerCase()
        var number = course.number.toLowerCase()
        if(!(name.includes(this.searchArchivedCourses.toLowerCase()) || number.includes(this.searchArchivedCourses.toLowerCase()))){return false}
      }
      if(this.termName.length){
        if(!(this.termName.includes(course.term.name))) {return false}
      }
      if(this.termYear.length){
        if (!(this.termYear.includes(course.term.year))){return false}
      }
      return course
    },
    openCopyCourseForm(course){
      console.log("copy course form course: ", course)
      this.selectedCourse = course
      this.newCopiedCourse.id = course.id
      this.newCopiedCourse.number = course.number
      this.newCopiedCourse.name = "Copy of " + course.name
      this.copyCourseForm = true
      this.copyCourseErrors = false
      this.modalState = true
    },
    openDeleteCourseModal(course){
      console.log("delete course form course: ", course)
      this.selectedCourse = course
      this.deleteCourseError = false
      this.deleteCourseModal = true
      this.modalState = true
    },
    openArchiveCourseModal(course){
      console.log("archive course form course: ", course)
      this.selectedCourse = course
      this.archiveCourseModal = true
      this.modalState = true
    },
    openUnpublishCourseModal(course){
      console.log("unpublish course form course: ", course)
      this.selectedCourse = course
      this.unpublishCourseModal = true
      this.modalState = true
    },
    openPublishCourseModal(course){
      console.log("publish course form course: ", course)
      this.selectedCourse = course
      this.publishCourseModal = true
      this.modalState = true
    },
    copyCourse(courseID){
      this.checkCopyCourseForm()

      if(!this.copyCourseErrors){
        this.copyingCourse = true
        this.newCopiedCourse.id = courseID
        this.$store.dispatch('copyCourse', this.newCopiedCourse)
      }
    },
    checkCopyCourseForm(){
      this.copyCourseErrors = false

      if(!this.newCopiedCourse.name || !this.newCopiedCourse.number){
        this.copyCourseErrors = true
      }
    },
    unpublishCourse(courseID){
      this.unpublishingCourse = true
      this.$store.dispatch('unpublishCourse', courseID)
    },
    publishCourse(courseID){
      this.publishingCourse = true
      this.$store.dispatch('publishCourse', courseID)
    },
    archiveCourse(courseID){
      this.archivingCourse = true
      this.$store.dispatch('archiveCourse', courseID)
    },
    deleteCourse(courseID){
      if(this.deleteConfirmation === 'DELETE'){
        this.deletingCourse = true
        this.$store.dispatch('deleteCourse', courseID)
      }
      else {
        this.deleteCourseError = true
      }
    },
    addCourse(){
      this.checkAddCourseForm()

      if(!this.newCourseErrors){
        this.addingCourse = true
        this.$store.dispatch('addNewCourse', this.newCourse)
      }
    },
    checkAddCourseForm(){
      this.newCourseErrors = false

      if(!this.newCourse.name || !this.newCourse.number){
        this.newCourseErrors = true
      }
    },
    close() {
      this.toggleModalState()
    },
    toggleModalState(){
      this.modalState = !this.modalState
      this.copyCourseForm = false
      this.deleteCourseModal = false
      this.archiveCourseModal = false
      this.unpublishCourseModal = false
      this.publishCourseModal = false
      this.showOnboarding = false
      this.addCourseModal = false
      this.selectedCourse = {}
    },
    revertToDefault(){
      this.copyCourseForm = false
      this.copyingCourse = false
      this.deleteCourseModal = false
      this.deletingCourse = false
      this.deleteConfirmation = ""
      this.deleteCourseError = false
      this.archiveCourseModal = false
      this.archivingCourse = false
      this.unpublishCourseModal = false
      this.unpublishingCourse = false
      this.publishCourseModal = false
      this.publishingCourse = false
      this.addingCourse = false
      this.addCourseModal = false
      this.selectedCourse = {}
    },
    sawOnboarding(){
      if(!this.hasSeenOnboarding){
        this.$store.dispatch('seenOnboarding')
      }
    },
    showOnboardingModal(){
      this.modalState = true
      this.showOnboarding = true
    }
  }
}
`</script>
