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
        {
          data: "votes_count",
          title: "Votes",
          // render: function (data, type, row) {
          //   // Mapping user_id to names
          //   const userNames = {
          //     1: "Cedric",
          //     2: "Raul",
          //     3: "Marco"
          //   };

          //   if (Array.isArray(data)) {
          //     return data
          //       .map((vote) => {
          //         let userName = userNames[vote.user_id] || `User ${vote.user_id}`;
          //         return `<strong>${userName}</strong>: ${vote.vote_value}`;
          //       })
          //       .join("<br>");
          //   }

          //   return data;
          // },
          render: function (data, type, row) {
            if (!Array.isArray(data)) return data;

            // Count votes
            let countStars = data.filter(vote => vote.vote_value === "star").length;
            let countYes = data.filter(vote => vote.vote_value === "yes").length;
            let countMaybe = data.filter(vote => vote.vote_value === "maybe").length;
            let countNo = data.filter(vote => vote.vote_value === "no").length;

            // If there is at least one star, the result is "OUI"
            if (countStars > 0) {
              return "YES" + " " + countStars + countYes + countMaybe + countNo;
            }

            // Determine the result based on conditions
            if (countYes === 3) {
              return "YES" + " " + countStars + countYes + countMaybe + countNo;
            } else if (
              (countYes === 1 && countMaybe === 2) ||
              (countYes === 2 && countMaybe === 1) ||
              (countYes === 1 && countMaybe === 1 && countNo === 1) ||
              (countYes === 2 && countNo === 1)
            ) {
              return "MAYBE+" + " " + countStars + countYes + countMaybe + countNo;
            } else if (
              (countYes === 1 && countNo === 2) ||
              countMaybe === 3 ||
              (countMaybe === 2 && countNo === 1)
            ) {
              return "MAYBE" + " " + countStars + countYes + countMaybe + countNo;
            } else if (countMaybe === 1 && countNo === 2) {
              return "NO" + " " + countStars + countYes + countMaybe + countNo;
            } else if (countNo === 3) {
              return "NO" + " " + countStars + countYes + countMaybe + countNo;
            } else {
              return "N/A" + " " + countStars + countYes + countMaybe + countNo;
            }
          }
        },
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
      ],
      search: {
        regex: true,
      },
      dom: "Bfrtip",
      buttons: ["copy", "csv", "excel", "pdf", "print"],
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

    // 🔹 Trigger search when typing
    $("#dashboard-table_filter input").on("keyup", function () {
      table.draw();
    });
  }
}
