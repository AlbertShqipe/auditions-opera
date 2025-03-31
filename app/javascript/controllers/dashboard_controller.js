import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.initDataTable();
  }

  initDataTable() {
    // 🔹 Destroy any existing instance to prevent duplication
    if ($.fn.DataTable.isDataTable("#dashboard-table")) {
      $("#dashboard-table").DataTable().destroy();
    }

    let table = $("#dashboard-table").DataTable({
      ajax: {
        url: "/dashboard/data",
        type: "GET",
        dataSrc: "data",
      },
      columns: [
        { data: "id", title: "ID" },
        {
          data: "name",
          title: "Name",
          render: function (data, type, row) {
            return `<a href="/audition_applications/${row.id}" target="_blank" class="link">${data}</a>`;
          }
        },
        { data: "nationality", title: "Nationality" },
        { data: "gender", title: "Gender" },
        { data: "application_status", title: "Status" },
        { data: "ethnicity", title: "Ethnicity" },
        // {
        //   data: "votes_count",
        //   title: "Votes",
        //   render: function (data, type, row) {
        //     if (!Array.isArray(data)) return data;

        //     // Count votes
        //     let countStars = data.filter(vote => vote.vote_value === "star").length;
        //     let countYes = data.filter(vote => vote.vote_value === "yes").length;
        //     let countMaybe = data.filter(vote => vote.vote_value === "maybe").length;
        //     let countNo = data.filter(vote => vote.vote_value === "no").length;

        //     let voteResult = `${countStars}⭐ | ${countYes}✅ | ${countMaybe}🟡 | ${countNo}🔴`;

        //     return voteResult;
        //   }
        // },
        //
        {
          data: "votes_count",
          title: "Votes",
          render: function (data, type, row) {
              if (!Array.isArray(data)) return data;

              // Lookup mapping for user names
              let userNames = {
                  1: 'MM',  // user_id 1 corresponds to MC
                  2: 'RS',  // user_id 2 corresponds to RS
                  3: 'CA',  // user_id 3 corresponds to CA
                  // Add more user ids and their corresponding names if needed
              };

              let voteHtml = '';

              // Function to convert vote value to corresponding icon
              function getVoteIcon(voteValue) {
                  switch (voteValue) {
                      case 'yes': return '✅';  // 'yes' vote
                      case 'maybe': return '🟡'; // 'maybe' vote
                      case 'no': return '🔴'; // 'no' vote
                      case 'star': return '⭐️'; // 'star' vote
                      default: return '❓'; // for undefined or not set votes
                  }
              }

              // Iterate over the votes data
              data.forEach(vote => {
                  let userName = userNames[vote.user_id] || `User ${vote.user_id}`; // Fallback to User ID if no name
                  let voteIcon = getVoteIcon(vote.vote_value);

                  // Construct HTML for each user's name and their vote icon, side-by-side
                  voteHtml += `<span style="display: inline-block; margin-right: 10px;">
                                  <strong>${userName}</strong>: ${voteIcon}
                                </span>`;
              });

            return voteHtml;
          }
        },
        {data: "result", title: "Result"},
        { data: "email",
          title: "Email",
          render: function (data) {
            return data ? `<a href="mailto:${data}" class="link">Contact</a>`: "";
          }
        },
        {
          data: "video_link",
          title: "URL",
          render: function (data) {
            return data ? `<a href="${data}" target="_blank" class="link">Video</a>` : "";
          }
        },
        {
          data: "cv",
          title: "CV",
          render: function (data) {
            return data ? `<a href="${data}" target="_blank" class="link">CV</a>` : "";
          }
        },
        {data: "confirmed_attendance", title: "Confirmed Attendance"}
      ],
      search: {
        regex: true,
      },
      dom: "lfrtipB",
      buttons: ["copy", "csv", "excel", "pdf", "print"],
      // 🔹 Set the default page length to 100 and options for the user
      "pageLength": 100,  // Set default to 100 rows per page
      "lengthMenu": [10, 25, 50, 100],  // Allow user to select 10, 25, 50, or 100 rows per page
    });

    // 🔹 Fix: Ensure the search works across multiple columns
    $.fn.dataTable.ext.search.push(function (settings, data, dataIndex) {
      let searchTerm = $("#dashboard-table_filter input").val().trim().toLowerCase();
      if (!searchTerm) return true; // Show all results if search is empty

      let searchableColumns = [1, 2, 3, 4, 5, 6, 7]; // Indices of searchable columns
      return searchableColumns.some((index) => {
        let cellData = (data[index] || "").toString().toLowerCase();
        return cellData.split(/\s+/).includes(searchTerm);
      });
    });

    // 🔹 Search Function for "Votes" Column
    $.fn.dataTable.ext.search.push(function (settings, data, dataIndex) {
      let searchTerm = $("#dashboard-table_filter input").val().trim().toLowerCase();
      if (!searchTerm) return true; // Show all if search is empty

      let voteColumnIndex = 6; // Adjust based on column position
      let voteData = data[voteColumnIndex] || "";

      return voteData.toLowerCase().includes(searchTerm);
    });

    // 🔹 Trigger search when typing
    $("#dashboard-table_filter input").on("keyup", function () {
      table.draw();
    });
  }
}
