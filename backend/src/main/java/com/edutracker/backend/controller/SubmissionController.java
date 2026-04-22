package com.edutracker.backend.controller;

import com.edutracker.backend.model.Submission;
import com.edutracker.backend.model.User;
import com.edutracker.backend.repository.UserRepository;
import com.edutracker.backend.service.SubmissionService;

import com.itextpdf.kernel.colors.DeviceRgb;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.*;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.borders.Border;
import com.itextpdf.layout.borders.SolidBorder;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import com.itextpdf.layout.properties.VerticalAlignment;

import java.io.ByteArrayOutputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/submissions")
@CrossOrigin(origins = "*")
public class SubmissionController {

    private final SubmissionService service;
    private final UserRepository userRepository;

    public SubmissionController(SubmissionService service, UserRepository userRepository) {
        this.service = service;
        this.userRepository = userRepository;
    }

    @PostMapping("/submit")
    public ResponseEntity<?> submit(@RequestBody Submission s) {
        try {
            Submission saved = service.submit(s);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500)
                    .body(Map.of("error", e.getMessage() != null ? e.getMessage() : "Unknown error"));
        }
    }

    @GetMapping("/student/{id}")
    public ResponseEntity<?> student(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.studentSubmissions(id));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/pending")
    public ResponseEntity<?> pending() {
        try {
            return ResponseEntity.ok(service.pendingWithStudent());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/approve/{id}")
    public ResponseEntity<?> approve(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.approve(id));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/reject/{id}")
    public ResponseEntity<?> reject(@PathVariable Long id,
                                    @RequestBody Map<String, String> body) {
        try {
            String remarks = body.getOrDefault("remarks", "");
            return ResponseEntity.ok(service.reject(id, remarks));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: compute the [start, end) LocalDateTime window for a semester.
    //
    //  batchYear = year extracted from roll-no (B23… → 2023)
    //  semester  = 1-based (1–8)
    //
    //  Year-of-admission mapping:
    //    Sem 1  → Jul–Dec  (batchYear)
    //    Sem 2  → Jan–Jun  (batchYear + 1)
    //    Sem 3  → Jul–Dec  (batchYear + 1)
    //    Sem 4  → Jan–Jun  (batchYear + 2)
    //    ...
    //  General formula (0-based index i = semester - 1):
    //    if i even  → July of (batchYear + i/2) .. end of Dec (batchYear + i/2)
    //    if i odd   → Jan  of (batchYear + (i+1)/2) .. end of Jun that year
    // ─────────────────────────────────────────────────────────────────────────
    private LocalDateTime[] semesterWindow(int semester, int batchYear) {
        int i = semester - 1;
        LocalDateTime start, end;
        if (i % 2 == 0) {
            int yr = batchYear + i / 2;
            start = LocalDateTime.of(yr, 7, 1, 0, 0);
            end   = LocalDateTime.of(yr, 12, 31, 23, 59, 59);
        } else {
            int yr = batchYear + (i + 1) / 2;
            start = LocalDateTime.of(yr, 1, 1, 0, 0);
            end   = LocalDateTime.of(yr, 6, 30, 23, 59, 59);
        }
        return new LocalDateTime[]{start, end};
    }

    // ─────────────────────────────────────────────────────────────────────────
    // NEW: JSON report – returns filtered submissions for the given semester
    //      batchYear is sent by the client (derived from roll number).
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/report-json/{studentId}/{semester}/{batchYear}")
    public ResponseEntity<?> reportJson(
            @PathVariable Long studentId,
            @PathVariable int semester,
            @PathVariable int batchYear) {
        try {
            List<Submission> all = service.studentSubmissions(studentId);
            LocalDateTime[] window = semesterWindow(semester, batchYear);
            LocalDateTime winStart = window[0];
            LocalDateTime winEnd   = window[1];

            // Fetch student info for the header
            User student = userRepository.findById(studentId).orElse(null);
            String studentName  = student != null ? student.getName()   : "";
            String studentRoll  = student != null ? student.getRollNo() : "";
            String studentDept  = student != null ? student.getDept()   : "";

            List<Map<String, Object>> rows = new ArrayList<>();
            int totalPoints = 0;

            for (Submission s : all) {
                if (!"APPROVED".equals(s.getStatus())) continue;
                if (s.getCreatedAt() == null) continue;
                LocalDateTime t = s.getCreatedAt();
                if (t.isBefore(winStart) || t.isAfter(winEnd)) continue;

                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id",            s.getId());
                row.put("title",         s.getTitle());
                row.put("activityGroup", s.getActivityGroup());
                row.put("category",      s.getCategory());
                row.put("level",         s.getLevel());
                row.put("points",        s.getPoints());
                row.put("submittedOn",   s.getCreatedAt()
                                          .format(DateTimeFormatter.ofPattern("dd MMM yyyy")));
                rows.add(row);
                totalPoints += s.getPoints();
            }

            Map<String, Object> response = new LinkedHashMap<>();
            response.put("studentName",  studentName);
            response.put("rollNo",       studentRoll);
            response.put("dept",         studentDept);
            response.put("semester",     semester);
            response.put("batchYear",    batchYear);
            response.put("periodStart",  winStart.format(DateTimeFormatter.ofPattern("MMM yyyy")));
            response.put("periodEnd",    winEnd.format(DateTimeFormatter.ofPattern("MMM yyyy")));
            response.put("totalPoints",  totalPoints);
            response.put("submissions",  rows);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // EXISTING: PDF report – professional table-based layout using iText7
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/report/{studentId}/{semester}/{batchYear}")
    public ResponseEntity<?> generateReport(
            @PathVariable Long studentId,
            @PathVariable int semester,
            @PathVariable int batchYear) {
        try {
            List<Submission> all = service.studentSubmissions(studentId);
            LocalDateTime[] window = semesterWindow(semester, batchYear);
            LocalDateTime winStart = window[0];
            LocalDateTime winEnd   = window[1];

            // Fetch student info
            User student = userRepository.findById(studentId).orElse(null);
            String sName = student != null ? student.getName()   : "Student";
            String sRoll = student != null ? student.getRollNo() : "";
            String sDept = student != null ? student.getDept()   : "";

            List<Submission> filtered = all.stream()
                    .filter(s -> "APPROVED".equals(s.getStatus()))
                    .filter(s -> s.getCreatedAt() != null)
                    .filter(s -> {
                        LocalDateTime t = s.getCreatedAt();
                        return !t.isBefore(winStart) && !t.isAfter(winEnd);
                    })
                    .toList();

            // ── Colors ──────────────────────────────────────────────────────
            DeviceRgb navyBlue  = new DeviceRgb(3,  48,  90);   // #03305A
            DeviceRgb green     = new DeviceRgb(29, 158, 117);  // #1D9E75
            DeviceRgb lightBg   = new DeviceRgb(237,243,250);   // #EDF3FA
            DeviceRgb borderCol = new DeviceRgb(216,227,237);   // #D8E3ED
            DeviceRgb white     = new DeviceRgb(255,255,255);
            DeviceRgb mutedText = new DeviceRgb(107,124,147);   // #6B7C93
            DeviceRgb darkText  = new DeviceRgb(3, 48, 90);

            DateTimeFormatter monthFmt = DateTimeFormatter.ofPattern("MMM yyyy");
            DateTimeFormatter dayFmt   = DateTimeFormatter.ofPattern("dd MMM yyyy");

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            PdfWriter   writer  = new PdfWriter(out);
            PdfDocument pdf     = new PdfDocument(writer);
            Document    document= new Document(pdf, PageSize.A4);
            document.setMargins(36, 36, 36, 36);

            // ══════════════════════════════════════════════════════════════
            // 1. TITLE BANNER
            // ══════════════════════════════════════════════════════════════
            Table banner = new Table(UnitValue.createPercentArray(new float[]{1}))
                    .useAllAvailableWidth()
                    .setMarginBottom(14);

            Cell bannerCell = new Cell()
                    .setBackgroundColor(navyBlue)
                    .setPadding(16)
                    .setBorder(Border.NO_BORDER);

            bannerCell.add(new Paragraph("EduTracker")
                    .setFontColor(new DeviceRgb(255,255,255))
                    .setFontSize(22)
                    .setBold()
                    .setMarginBottom(2));

            bannerCell.add(new Paragraph("Academic Activity Report  •  Semester " + semester
                    + "  (" + winStart.format(monthFmt) + " – " + winEnd.format(monthFmt) + ")")
                    .setFontColor(new DeviceRgb(200, 215, 230))
                    .setFontSize(10)
                    .setMarginBottom(0));

            banner.addCell(bannerCell);
            document.add(banner);

            // ══════════════════════════════════════════════════════════════
            // 2. STUDENT INFO CARD  (2-column row)
            // ══════════════════════════════════════════════════════════════
            Table infoTable = new Table(UnitValue.createPercentArray(new float[]{1, 1}))
                    .useAllAvailableWidth()
                    .setMarginBottom(18);

            // Left cell
            Cell leftInfo = new Cell()
                    .setBackgroundColor(lightBg)
                    .setPadding(12)
                    .setBorder(new SolidBorder(borderCol, 1));
            leftInfo.add(new Paragraph("Student Name").setFontSize(8).setFontColor(mutedText).setBold().setMarginBottom(2));
            leftInfo.add(new Paragraph(sName).setFontSize(12).setBold().setFontColor(darkText).setMarginBottom(8));
            leftInfo.add(new Paragraph("Department").setFontSize(8).setFontColor(mutedText).setBold().setMarginBottom(2));
            leftInfo.add(new Paragraph(sDept).setFontSize(11).setFontColor(darkText));
            infoTable.addCell(leftInfo);

            // Right cell
            Cell rightInfo = new Cell()
                    .setBackgroundColor(lightBg)
                    .setPadding(12)
                    .setBorder(new SolidBorder(borderCol, 1));
            rightInfo.add(new Paragraph("Roll Number").setFontSize(8).setFontColor(mutedText).setBold().setMarginBottom(2));
            rightInfo.add(new Paragraph(sRoll).setFontSize(12).setBold().setFontColor(darkText).setMarginBottom(8));
            rightInfo.add(new Paragraph("Batch Year").setFontSize(8).setFontColor(mutedText).setBold().setMarginBottom(2));
            rightInfo.add(new Paragraph(String.valueOf(batchYear)).setFontSize(11).setFontColor(darkText));
            infoTable.addCell(rightInfo);

            document.add(infoTable);

            // ══════════════════════════════════════════════════════════════
            // 3. ACTIVITIES TABLE
            // ══════════════════════════════════════════════════════════════
            // Columns: S.No | Activity Title | Category | Level | Points | Date
            float[] colWidths = {4f, 30f, 20f, 10f, 10f, 16f};
            Table actTable = new Table(UnitValue.createPercentArray(colWidths))
                    .useAllAvailableWidth()
                    .setMarginBottom(8);

            // Table header row
            String[] headers = {"#", "Activity Title", "Category", "Level", "Points", "Date"};
            for (String h : headers) {
                actTable.addHeaderCell(
                        new Cell()
                                .setBackgroundColor(navyBlue)
                                .setPadding(8)
                                .setBorder(Border.NO_BORDER)
                                .add(new Paragraph(h)
                                        .setFontColor(white)
                                        .setFontSize(9)
                                        .setBold()
                                        .setTextAlignment(TextAlignment.CENTER))
                );
            }

            // Data rows
            int total = 0;
            for (int idx = 0; idx < filtered.size(); idx++) {
                Submission s  = filtered.get(idx);
                boolean isEven = (idx % 2 == 0);
                DeviceRgb rowBg = isEven ? white : lightBg;

                String dateTxt = s.getCreatedAt() != null
                        ? s.getCreatedAt().format(dayFmt) : "—";

                // S.No
                actTable.addCell(tableCell(String.valueOf(idx + 1), rowBg, borderCol, TextAlignment.CENTER, false));
                // Title
                actTable.addCell(tableCell(
                        s.getTitle() != null ? s.getTitle() : (s.getActivityGroup() != null ? s.getActivityGroup() : "—"),
                        rowBg, borderCol, TextAlignment.LEFT, true));
                // Category
                actTable.addCell(tableCell(s.getCategory() != null ? s.getCategory() : "—", rowBg, borderCol, TextAlignment.LEFT, false));
                // Level
                actTable.addCell(tableCell(s.getLevel() != null ? s.getLevel() : "—", rowBg, borderCol, TextAlignment.CENTER, false));
                // Points
                actTable.addCell(tableCell(String.valueOf(s.getPoints()), rowBg, borderCol, TextAlignment.CENTER, true));
                // Date
                actTable.addCell(tableCell(dateTxt, rowBg, borderCol, TextAlignment.CENTER, false));

                total += s.getPoints();
            }

            // Empty state row
            if (filtered.isEmpty()) {
                Cell emptyCell = new Cell(1, 6)
                        .setBackgroundColor(lightBg)
                        .setPadding(16)
                        .setBorder(new SolidBorder(borderCol, 1))
                        .add(new Paragraph("No approved activities found for this semester.")
                                .setFontColor(mutedText)
                                .setFontSize(10)
                                .setTextAlignment(TextAlignment.CENTER));
                actTable.addCell(emptyCell);
            }

            document.add(actTable);

            // ══════════════════════════════════════════════════════════════
            // 4. TOTAL POINTS ROW
            // ══════════════════════════════════════════════════════════════
            Table totalTable = new Table(UnitValue.createPercentArray(new float[]{1, 1}))
                    .useAllAvailableWidth()
                    .setMarginBottom(28);

            Cell totalLabel = new Cell()
                    .setBackgroundColor(green)
                    .setPadding(10)
                    .setBorder(Border.NO_BORDER)
                    .add(new Paragraph("Total Points Earned This Semester")
                            .setFontColor(white)
                            .setFontSize(11)
                            .setBold());
            totalTable.addCell(totalLabel);

            Cell totalValue = new Cell()
                    .setBackgroundColor(green)
                    .setPadding(10)
                    .setBorder(Border.NO_BORDER)
                    .setVerticalAlignment(VerticalAlignment.MIDDLE)
                    .add(new Paragraph(String.valueOf(total))
                            .setFontColor(white)
                            .setFontSize(16)
                            .setBold()
                            .setTextAlignment(TextAlignment.RIGHT));
            totalTable.addCell(totalValue);

            document.add(totalTable);

            // ══════════════════════════════════════════════════════════════
            // 5. FOOTER
            // ══════════════════════════════════════════════════════════════
            document.add(new Paragraph(
                    "Generated by EduTracker  •  " +
                    LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")))
                    .setFontSize(8)
                    .setFontColor(mutedText)
                    .setTextAlignment(TextAlignment.CENTER));

            document.close();

            return ResponseEntity.ok()
                    .header("Content-Disposition", "attachment; filename=report_sem" + semester + ".pdf")
                    .header("Content-Type", "application/pdf")
                    .body(out.toByteArray());

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    // Helper: create a styled table cell
    private Cell tableCell(String text, DeviceRgb bg, DeviceRgb border,
                           TextAlignment align, boolean bold) {
        Paragraph p = new Paragraph(text)
                .setFontSize(9)
                .setTextAlignment(align);
        if (bold) p.setBold();

        return new Cell()
                .setBackgroundColor(bg)
                .setPadding(7)
                .setBorder(new SolidBorder(border, 0.5f))
                .add(p);
    }

    // Keep old 2-param endpoint for backward compat (falls back to current year batch)
    @GetMapping("/report/{studentId}/{semester}")
    public ResponseEntity<?> generateReportLegacy(
            @PathVariable Long studentId,
            @PathVariable int semester) {
        return generateReport(studentId, semester, 2023);
    }
}
